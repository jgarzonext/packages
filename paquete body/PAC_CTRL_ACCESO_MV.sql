--------------------------------------------------------
--  DDL for Package Body PAC_CTRL_ACCESO_MV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CTRL_ACCESO_MV" IS

------------------------------------------------------------------------------
--  F_acceso_poliza
--    Funció que indica si aquesta póliza es pot visualitzar, modificar, o no
--	  per un cert usuari:
--	  	   0: Sin restricción
--		   1: Visible i modificable
--		   2: No visible
--		   3: Visible però no modificable
--    CPM 27/1/04
------------------------------------------------------------------------------
FUNCTION f_acceso_poliza (psperson IN NUMBER, ptipousu IN NUMBER,
		 				 poficina IN VARCHAR2) RETURN NUMBER IS

  resultat  NUMBER;

BEGIN

  IF ptipousu = 1 THEN  			-- Terminalista

	SELECT count(1) INTO resultat
	FROM SEGUROS s, TOMADORES t
	WHERE s.cagente = poficina
	  AND s.sseguro = t.sseguro
	  AND t.sperson = psperson;

	IF resultat = 0 THEN
	   return 2;
	ELSE
	   return 1;
	END IF;

  ELSIF ptipousu = 0 THEN		-- Central
  	return 0;
  ELSE
  	return 0;
  END IF;

END f_acceso_poliza;

------------------------------------------------------------------------------
--  Tipo_usuario
--    Funció que retorna el tipus d'usuari d'accés:
--	    0: Usuari de la central --> no té accés al host i per tant és el
--                  tipus d'usuari menys perillós
--		1: Usuari de terminal financer --> és un usuari amb connexió real al host
--		2: Usuari de desenvolupament --> sempre es connecta al host amb l'usuari
--                 2222 i l'oficina 252
--    EAS 28/1/04
------------------------------------------------------------------------------
FUNCTION tipo_usuario (puser in varchar2, ptipousuario out varchar2)
    RETURN NUMBER IS
  vcrolmen varchar2(20);
  vcusuari varchar2(20);

BEGIN
  begin
    select cusuari
      into vcusuari
      from usuarios
	  where replace(upper(cusuari),'TF_','') = replace(upper(puser),'TF_','');
  exception
    when too_many_rows then
      select cusuari
        into vcusuari
        from usuarios
	    where upper(cusuari) = upper(puser);
	when no_data_found then
      return 151318; -- usuario no existe
	when others then
      return 151319;  -- error al buscar el tipo de usuario
  end;

  begin
    select crolmen
      into vcrolmen
      from dsiusurol
      where cusuari = vcusuari
      and crolmen = 'DESARROLLO';
  exception
    when no_data_found then
	  begin
        select crolmen
          into vcrolmen
          from dsiusurol
          where cusuari = vcusuari
          and crolmen = 'TF_TOTAL';
	  exception
		when no_data_found then
		  begin
		    select crolmen
		      into vcrolmen
		      from dsiusurol
		      where cusuari = F_USER
		      and crolmen = 'DESARROLLO';
		  exception
		    when others then
          		 vcrolmen := 'ALTRES';
	      end;
		when others then
          vcrolmen := 'ALTRES';
	  end;
    when others then
	  vcrolmen := 'ALTRES';
  end;

  if vcrolmen = 'DESARROLLO' then
    ptipousuario := 2;
  elsif vcrolmen = 'TF_TOTAL' then
    ptipousuario := 1;
  else
    ptipousuario := 0;
  end if;
  return 0;


EXCEPTION
  WHEN others then
	return 151319;  -- error al buscar el tipo de usuario
END tipo_usuario;


FUNCTION usuario_host(puser in varchar2, puserhost out varchar2) RETURN number IS
  -------------------------------------------------------------------------------
  --   Dado un usuario de sistema (f_os_user) esta función retorna el usuario de
  --     base de datos si el tipo de usuario és 1 (usuario de Terminal Financiero).
  --     Si el tipo de usuario es 2 (usuario de desarrollo), siempre devuelve '2222'
  --     ya que es el usuario de pruebas. Si el tipo se usuario es 0 (usuario de
  --     central), devuelve el usuario de base de datos
  -------------------------------------------------------------------------------
  v_error 	    number;
  v_tipousuario number;
BEGIN
  v_error := tipo_usuario (puser, v_tipousuario);
  if v_error <> 0 then
    return (v_error);
  end if;
  if v_tipousuario = 1 then
    puserhost :=  substr(puser,4);
  elsif v_tipousuario = 2 then
    puserhost := '2222';
  elsif v_tipousuario = 0 then
    puserhost := F_USER;
  else
    return 151320; -- error al buscar el usuario de host
  end if;
  return 0;
END usuario_host;


FUNCTION f_es_host (p_user in varchar2, p_host out number)
 	RETURN NUMBER IS
  -------------------------------------------------------------------------------
  --   Esta función retorna si el usuario es de host (1) o no (o)
  -------------------------------------------------------------------------------
  v_error 	    number;
  v_tipousuario number;
BEGIN
  v_error := tipo_usuario (p_user, v_tipousuario);
  if v_error <> 0 then
    return (v_error);
  end if;
  if v_tipousuario IN (1, 2) then
    --se incluye desarrollo en los usuarios que tienen conexión con el host
    p_host := 1;
  else
    p_host := 0;
  end if;
  return 0;
END f_es_host;


END Pac_Ctrl_Acceso_MV;

/

  GRANT EXECUTE ON "AXIS"."PAC_CTRL_ACCESO_MV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CTRL_ACCESO_MV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CTRL_ACCESO_MV" TO "PROGRAMADORESCSI";
