library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity log2_taylor is
    port (
        clk    : in  std_logic;
        reset  : in  std_logic;
        din    : in  std_logic_vector(15 downto 0); -- Входное число (unsigned)
        dout   : out std_logic_vector(15 downto 0)  -- Выход Q4.12 (4 бита целых, 12 дробных)
    );
end entity;

architecture rtl of log2_taylor is
    -- Коэффициенты Q14 (масштаб 2^14 = 16384) [1]
    constant C0 : signed(15 downto 0) := x"2570"; --  0.5849 (log2(1.5))
    constant C1 : signed(15 downto 0) := x"3D86"; --  0.9617
    constant C2 : signed(15 downto 0) := x"EB7B"; -- -0.3205
    constant C3 : signed(15 downto 0) := x"091F"; --  0.1424
    constant C4 : signed(15 downto 0) := x"FB71"; -- -0.0712

    -- Сигналы нормализации
    signal exponent_reg : integer range 0 to 15;
    signal y            : signed(15 downto 0); -- y = m - 1.5

    -- Конвейер для DSP (9 стадий согласно источнику [3])
    type pipe_array is array (0 to 8) of signed(31 downto 0);
    signal p : pipe_array := (others => (others => '0'));

    -- Конвейер для экспоненты (чтобы выровнять с задержкой DSP)
    type exp_pipe is array (0 to 8) of integer range 0 to 15;
    signal e_delay : exp_pipe := (others => 0);

begin

    -- 1. Поиск ведущей единицы и нормализация (1 такт)
    process(clk)
        variable lead_bit : integer range 0 to 15;
    begin
        if rising_edge(clk) then
            lead_bit := 0;
            for i in 15 downto 0 loop
                if din(i) = '1' then
                    lead_bit := i;
                    exit;
                end if;
            end loop;

            exponent_reg <= lead_bit;
            -- Нормализация: сдвигаем число так, чтобы m было в [1, 2)
            -- В формате Q14: 1.0 = 0x4000, 1.5 = 0x6000, 2.0 = 0x8000
            -- y = m - 1.5
            y <= signed(shift_left(unsigned(din), 14 - lead_bit)) - x"6000";
        end if;
    end process;

    -- 2. Вычисление полинома по схеме Горнера (7 DSP блоков) [2, 4]
    -- Формула: C0 + y*(C1 + y*(C2 + y*(C3 + y*C4)))
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                p <= (others => (others => '0'));
                e_delay <= (others => 0);
            else
                -- Согласование задержки экспоненты с конвейером DSP
                e_delay(0) <= exponent_reg;
                for i in 1 to 8 loop
                    e_delay(i) <= e_delay(i-1);
                end loop;

                -- Стадии MAC (Multiply-Accumulate)
                -- Каждая пара p(n) эффективно ложится в DSP48E1
                p(0) <= y * C4;                                         -- y*C4
                p(1) <= p(0) + shift_left(resize(C3, 32), 14);          -- + C3
                p(2) <= y * p(1)(29 downto 14);                         -- y*(...)
                p(3) <= p(2) + shift_left(resize(C2, 32), 14);          -- + C2
                p(4) <= y * p(3)(29 downto 14);                         -- y*(...)
                p(5) <= p(4) + shift_left(resize(C1, 32), 14);          -- + C1
                p(6) <= y * p(5)(29 downto 14);                         -- y*(...)
                p(7) <= p(6) + shift_left(resize(C0, 32), 14);          -- + C0
                p(8) <= p(7); -- Финальный такт
            end if;
        end if;
    end process;

    -- 3. Формирование результата: Эксп (целое) + Мантисса (дробь) [5]
    -- Берем биты, соответствующие формату Q12 дробной части
    dout <= std_logic_vector(to_unsigned(e_delay(8), 4)) &
            std_logic_vector(p(8)(25 downto 14));

end architecture;

