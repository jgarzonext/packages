CREATE OR REPLACE FUNCTION ff_buscadatosSAP(
   sap_busca IN NUMBER,
   sap_cuenta IN varchar2)
RETURN number  IS
/*****************************************************************
   ff_buscadatosSAP:  Retorna los valores requeridos segun cuenta para la contabilizacion en SAP
   Autor:                      Wilson Andres Jaime
   Fecha:                      14/05/2019
*****************************************************************/

x_tipo_liquidacion number;
x_posicion number;
x_sproduc number;
x_cactivi number;
x_produc number;
X_FEMISIO   DATE;
X_FEFECTO   DATE;
X_VIGFUT    NUMBER := 0;
X_TIPREG    NUMBER;

begin
   if sap_busca in (1, 2, 3, 4, 5, 6, 7, 8, 10, 12) then

	  SELECT TIPLIQ
		into x_tipo_liquidacion
	  FROM TIPO_LIQUIDACION
	  WHERE CUENTA = sap_cuenta;
    --Iaxis 4504 AABC 05/09/2019 validacion de sucursal 
    -- X_TIPREG = 1 Poliza 
    -- X_TIPREG = 2 Siniestros 
    SELECT NVL(pac_subtablas.f_vsubtabla (pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24,'USER_BBDD')), 9000022, 3, 2, sap_cuenta),1)
      INTO X_TIPREG 
      FROM dual;
    --Iaxis 4504 AABC 05/09/2019 validacion de sucursal
/*
	  if x_tipo_liquidacion in (13, 14, 57, 16, 41)  then
		 if sap_busca = 1 then
			x_posicion := 138;
		 end if;
		  if sap_busca = 2 then
			x_posicion := 241;
		 end if;
		  if sap_busca = 3 then
			x_posicion := 70;
		 end if;
		  if sap_busca = 4 then
			x_posicion := 231;
		 end if;
		  if sap_busca = 5 then
			x_posicion := 257;
		 end if;
		  if sap_busca = 6 then
			x_posicion := 277;
		 end if;
		  if sap_busca = 7 then
			x_posicion := 279;
		 end if;
		  if sap_busca = 8 then
			x_posicion := 152;
		  end if;
      if sap_busca = 10 then
			x_posicion := 90;
		  end if;
        if sap_busca = 12 then
			x_posicion := 312;
		  end if;
	  else*/
		 if sap_busca = 1 then
			x_posicion := 139;
		 end if;
                 --Iaxis 4504 AABC 05/09/2019 validacion de sucursal 
                 if sap_busca = 2 AND X_TIPREG = 1 then
			x_posicion := 242;
		 end if;
                 if sap_busca = 2 AND X_TIPREG = 2 then
                        x_posicion := 15;
                 end if;
                 --Iaxis 4504 AABC 05/09/2019 validacion de sucursal 
		  if sap_busca = 3 then
			x_posicion := 71;
		 end if;
		  if sap_busca = 4 then
			x_posicion := 232;
		 end if;
		  if sap_busca = 5 then
			x_posicion := 258;
		 end if;
		  if sap_busca = 6 then
			x_posicion := 278;
		 end if;
		  if sap_busca = 7 then
			x_posicion := 280;
		 end if;
		  if sap_busca = 8 then
			x_posicion := 153;
		  end if;
       if sap_busca = 10 then
			x_posicion := 91;
		  end if;
         if sap_busca = 12 then
			x_posicion := 313;
		  end if;
	  --end if;
   end if;
   --validacion de productos
   if sap_busca = 9 then
      select sproduc, cactivi
	     into x_sproduc, x_cactivi
	  from seguros
	  where sseguro = sap_cuenta;

	  x_produc := x_sproduc;

	  select  SUBSTR(CNV_SPR,INSTR(CNV_SPR,'|')+1,LENGTH(CNV_SPR))
				into x_posicion
	  from CNVPRODUCTOS_EXT
	  where sproduc = x_produc;

	  if x_sproduc = 80004 then
	     if  x_cactivi = 1 then
		    x_produc := 8013;
			select  SUBSTR(CNV_SPR,INSTR(CNV_SPR,'|')+1,LENGTH(CNV_SPR))
				into x_posicion
			from CNVPRODUCTOS_EXT
			where sproduc = x_produc;
		 end if;
	     if  x_cactivi = 2 then
		    x_produc := 8029;
			select  SUBSTR(CNV_SPR,INSTR(CNV_SPR,'|')+1,LENGTH(CNV_SPR))
				into x_posicion
			from CNVPRODUCTOS_EXT
			where sproduc = x_produc;
	     end if;
		 if  x_cactivi = 3 then
		    x_produc := 8021;
			select  SUBSTR(CNV_SPR,INSTR(CNV_SPR,'|')+1,LENGTH(CNV_SPR))
				into x_posicion
			from CNVPRODUCTOS_EXT
			where sproduc = x_produc;
	     end if;
      end if;

	   if x_sproduc in (80005, 80006) then
	     if  x_cactivi = 1 then
		    x_produc := 8014;
			select  SUBSTR(CNV_SPR,INSTR(CNV_SPR,'|')+1,LENGTH(CNV_SPR))
				into x_posicion
			from CNVPRODUCTOS_EXT
			where sproduc = x_produc;
	     end if;
	     if  x_cactivi = 2 then
		    x_produc := 8030;
			select  SUBSTR(CNV_SPR,INSTR(CNV_SPR,'|')+1,LENGTH(CNV_SPR))
				into x_posicion
			from CNVPRODUCTOS_EXT
			where sproduc = x_produc;
	     end if;
		 if  x_cactivi = 3 then
		    x_produc := 8023;
			select  SUBSTR(CNV_SPR,INSTR(CNV_SPR,'|')+1,LENGTH(CNV_SPR))
				into x_posicion
			from CNVPRODUCTOS_EXT
			where sproduc = x_produc;
	     end if;
      end if;

	  if x_sproduc = 80001 then
	     if  x_cactivi = 1 then
		    x_produc := 8009;
			select  SUBSTR(CNV_SPR,INSTR(CNV_SPR,'|')+1,LENGTH(CNV_SPR))
				into x_posicion
			from CNVPRODUCTOS_EXT
			where sproduc = x_produc;
	     end if;
	     if  x_cactivi = 2 then
		    x_produc := 8025;
			select  SUBSTR(CNV_SPR,INSTR(CNV_SPR,'|')+1,LENGTH(CNV_SPR))
				into x_posicion
			from CNVPRODUCTOS_EXT
			where sproduc = x_produc;
	     end if;
		 if  x_cactivi = 3 then
		    x_produc := 8017;
			select  SUBSTR(CNV_SPR,INSTR(CNV_SPR,'|')+1,LENGTH(CNV_SPR))
				into x_posicion
			from CNVPRODUCTOS_EXT
			where sproduc = x_produc;
	     end if;
      end if;

	  if x_sproduc in (80002, 80003) then
       if  x_cactivi = 0 then
        x_produc := 8002;
      select  SUBSTR(CNV_SPR,INSTR(CNV_SPR,'|')+1,LENGTH(CNV_SPR))
        into x_posicion
      from CNVPRODUCTOS_EXT
      where sproduc = x_produc;
       end if;
	     if  x_cactivi = 1 then
		    x_produc := 8010;
			select  SUBSTR(CNV_SPR,INSTR(CNV_SPR,'|')+1,LENGTH(CNV_SPR))
				into x_posicion
			from CNVPRODUCTOS_EXT
			where sproduc = x_produc;
	     end if;
	     if  x_cactivi = 2 then
		    x_produc := 8027;
			select  SUBSTR(CNV_SPR,INSTR(CNV_SPR,'|')+1,LENGTH(CNV_SPR))
				into x_posicion
			from CNVPRODUCTOS_EXT
			where sproduc = x_produc;
	     end if;
		 if  x_cactivi = 3 then
		    x_produc := 8003;
			select  SUBSTR(CNV_SPR,INSTR(CNV_SPR,'|')+1,LENGTH(CNV_SPR))
				into x_posicion
			from CNVPRODUCTOS_EXT
			where sproduc = x_produc;
	     end if;
      end if;
   end if; 

   --validacion de coaseguros
   if sap_busca = 11 then
      select ctipcoa
        into x_sproduc
      from seguros
      where sseguro = sap_cuenta;

      if x_sproduc = 0 then
        x_posicion := 260;
      end if;
      if x_sproduc = 1 then
        
         --validacion vigencia furuta
          select trunc(femisio), trunc(fefecto)
            into x_femisio, x_fefecto
            from seguros a
           where sseguro = sap_cuenta;

          if x_fefecto > x_femisio then
            x_vigfut := 1; --Vig. Futura
            x_posicion := 346; 
          else
            x_vigfut := 0; --Vig. Actual
            x_posicion := 261;
          end if;   
        
      end if;
      if x_sproduc = 8 then
        x_posicion := 262;
      end if;
   end if; 

  return (x_posicion);
end;
