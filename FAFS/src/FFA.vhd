library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity FFA is 
	generic (N : natural := 8; -- FW input with
		 P : integer := 3); -- Number of clock phases
	port (FW : in std_logic_vector (N-1 downto 0);
	      en : in std_logic;
	      ffa : inout std_logic);
end entity;

architecture behavioral of FFA is
--
--  function log2 (n : natural) return integer is
--      variable m, p : integer;
--      begin
--        m := 0;
--        p := 1;
--        for i in 0 to n loop
--          if p < n then
--            m := m + 1;
--            p := p * 2;
--          end if;
--        end loop;
--      return m;
--  end log2;
--
signal r : std_logic_vector (P-1 downto 0);
signal clks : std_logic_vector (2**P downto 0);
signal reg_out, reg_in : std_logic_vector (N-1 downto 0);
signal m : std_logic;

begin
	clks(0) <= en nand clks(2**P) after 1 ns;
	S: for i in 1 to 2**P generate
		clks(i) <= not clks(i-1) after 1 ns;
	end generate S;

m <= clks(to_integer(unsigned(r))) after 1 ns;

process (m, en)
	begin
		if en <= '0' then
			reg_out <= (others => '0');
		elsif rising_edge(m) then
			reg_out <= reg_in;
			-- reg_out <= reg_out + FW;
		end if; 	
end process;

reg_in <= reg_out  + FW;

process (m, en)
	begin
		if en = '0' then
			ffa <= '0';
		elsif rising_edge(m) then
			ffa <= not ffa;
		end if;
end process;

r <= reg_out(P-1 downto 0);

end architecture;