-- Quartus II VHDL Template
-- Four-State Moore State Machine

-- A Moore machine's outputs are dependent only on the current state.
-- The output is written only when the state changes.  (State
-- transitions are synchronous.)

library ieee;
use ieee.std_logic_1164.all;

entity VGA is

	port(
		clk_fpga		 : in	std_logic;
		
		rojo, verde, azul, rojo_cuad, verde_cuad,azul_cuad: in std_logic_vector(2 downto 0);
		
		
		reset	 : in	std_logic;
		
		VGA_HS, VGA_VS: out std_logic;
		Rojo_out, Verde_out, Azul_out :out std_logic_vector(9 downto 0);
		VGA_blank, VGA_sync, VGA_clk: out std_logic
		
	);

end entity;

architecture VGA of vga is

	-- Build an enumerated type for the state machine
	type state_type_HS is (s_aHS, s_bHS, s_cHS, s_dHS);
	type state_type_VS is (s_aVS, s_bVS, s_cVS, s_dVS);
	-- Register to hold the current state
	signal state_HS   : state_type_HS;
	signal state_VS   : state_type_VS;
	
	signal clk: std_logic;
	signal count_clk: integer := 0;
	signal count_Linea: integer := 0;
	
	
	signal H_Blank, V_Blank:std_logic;
	
	signal cuad_H:integer;
	signal cuad_V:integer;
	signal cuad_H_f:integer;
	signal cuad_V_f:integer;
begin


Process(rojo,verde,azul, rojo_cuad,verde_cuad,azul_cuad,clk,clk_fpga)
--color out
begin
	if (count_clk>cuad_H) and (count_clk<cuad_H_f) and (count_Linea>cuad_V) and (count_Linea<cuad_V_f) then

			Rojo_out(9 downto 7)  <= rojo_cuad;
			Rojo_out(6 downto 0)  <= "0000000";

			Azul_out(9 downto 7)  <= azul_cuad;
			Azul_out(6 downto 0)  <= "0000000";

			Verde_out(9 downto 7) <= verde_cuad;
			Verde_out(6 downto 0) <= "0000000";

	else
			Rojo_out(9 downto 7) <= rojo;
			Rojo_out(6 downto 0) <= "0000000";		
		
			Azul_out(9 downto 7) <= azul;
			Azul_out(6 downto 0) <= "0000000";

			Verde_out(9 downto 7) <= verde;
			Verde_out(6 downto 0) <= "0000000";
	end if;
end process;



--clk lowering

	process(clk_fpga, reset, clk)
--	variable cnt: integer:=0;
	
	begin
--		if reset='0' then 
--			cnt :=0;
--			clk <= '0';
--		else
--			if (clk_fpga'event and clk_fpga='1') then
--				if cnt=1 then
--					cnt :=0;
--					clk <= '1';
--				else
--					cnt := cnt +1;
--					clk <= '0';
--				end if;
--			end if;
--		end if;
		if reset = '0' then
			clk <= '0';
			cuad_H<=444;--Cuadrado de 40x40--
			cuad_V<=255;
			cuad_H_f<=cuad_H+40;
			cuad_V_f<=cuad_V+40;
		elsif (rising_edge(clk_fpga)) then
			clk <= not(clk);
		end if;
	end process;

process(clk)
begin

	if (rising_edge(clk)) then
		count_clk <= count_clk+1;
		if count_clk=800 then
			count_Linea <= count_Linea+1;
			count_clk <= 0;
			if count_Linea=515 then
				count_Linea <= 0;
			end if;
		end if;
	end if;

end process;



	-- Logic to advance to the next state
-- VGA_HS Maquina de estado	
	process (clk, reset)
	begin
		if reset = '0' then
			state_HS <= s_aHS;
		elsif (rising_edge(clk)) then
			case state_HS is
			
				when s_aHS =>
					if count_clk = 96 then
						state_HS <= s_bHS;
					else
						state_HS <= s_aHS;
					end if;
					
				when s_bHS=>
					if count_clk = 144 then
						state_HS <= s_cHS;
					else	
						state_HS <= s_bHS;
					end if;
					
				when s_cHS=>
					if count_clk = 784 then
						state_HS <= s_dHS;
					else
						state_HS <= s_cHS;
					end if;
					
				when s_dHS =>
					if count_clk = 800 then
						state_HS <= s_aHS;
					
					else
						state_HS <= s_dHS;
					end if;
			end case;
		end if;
	end process;

	-- Output depends solely on the current state
	process (state_HS)
	begin
		case state_HS is
			when s_aHS =>
				VGA_HS <= '0';
				H_Blank <= '0';
				
			when s_bHS =>
				VGA_HS <= '1';
				H_Blank <= '0';
				
			when s_cHS =>
				VGA_HS <= '1';
				H_Blank <= '1';
				
			when s_dHS =>
				VGA_HS <= '1';
				H_Blank <= '0';
				
		end case;
	end process;
	
	
	
	
	
--Maquina de estado VGA_VS
	process (clk, reset)
	begin
		if reset = '0' then
			state_VS <= s_aVS;
		elsif (rising_edge(clk)) then
			case state_VS is
			
				when s_aVS =>
					if count_Linea = 2 then
						state_VS <= s_bVS;
					else
						state_VS <= s_aVS;
					end if;
					
				when s_bVS=>
					if count_Linea = 35 then
						state_VS <= s_cVS;
					else	
						state_VS <= s_bVS;
					end if;
					
				when s_cVS=>
					if count_Linea = 505 then
						state_VS <= s_dVS;
					else
						state_VS <= s_cVS;
					end if;
					
				when s_dVS =>
					if count_Linea = 515 then
						state_VS <= s_aVS;
					
					else
						state_VS <= s_dVS;
					end if;
			end case;
		end if;
	end process;

	-- Output depends solely on the current state
	process (state_VS)
	begin
		case state_VS is
			when s_aVS =>
				VGA_VS <= '0';
				V_Blank <= '0';
				
			when s_bVS =>
				VGA_VS <= '1';
				V_Blank <= '0';
				
			when s_cVS =>
				VGA_VS <= '1';
				V_Blank <= '1';
				
			when s_dVS =>
				VGA_VS <= '1';
				V_Blank <= '0';
				
		end case;
	end process;
	
	VGA_blank <= (H_Blank and V_Blank);
	VGA_sync <= '0';
	VGA_clk <= clk;

end vga;