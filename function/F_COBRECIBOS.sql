--------------------------------------------------------
--  DDL for Function F_COBRECIBOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_COBRECIBOS" ( psproduc  NUMBER, psseguro NUMBER, pnrecibo NUMBER,
                                             pusucobro VARCHAR2, pfcobro DATE)
RETURN NUMBER authid current_user IS
/***********************************************************************
 F_COBRECIBOS: Rutina que genere el cobro de recibos de forma masiva.
    Parámetros de entrada:
    - sproduc
    - npoliza
    - nrecibo
    - Usuario de cobro por defecto f_user.
    - Fecha cobro por defecto sysdate.
    Parámetros de salida:
            0 Si todo correcto
     nocobrados Nº Total de recibos con error.
     Inserta mensajes de error en TAB_ERROR
  CREACIÓN: JAMVER 31/01/2008
***********************************************************************/
    error_num    NUMBER := 0;
    w_smovrecibo NUMBER := 0;
    w_nliqmen    NUMBER;
    w_nliqlin    NUMBER;
    nocobrados   NUMBER:=0;
CURSOR tratar IS
 SELECT r.nrecibo ,r.cdelega, r.ccobban,
        s.sproduc ,s.cramo ,s.cmodali ,s.ctipseg ,s.ccolect ,m.fmovini,
        r.cagente ,s.cagrpro ,s.ccompani ,r.cempres,
        r.sseguro ,r.ctiprec ,r.cbancar ,r.nmovimi ,r.fefecto
   FROM seguros s, recibos r, movrecibo m
  WHERE s.sproduc = NVL(psproduc, s.sproduc)
    AND s.sseguro = NVL(psseguro, s.sseguro)
    AND r.nrecibo = NVL(pnrecibo, r.nrecibo)
    AND (r.cestimp = 4 OR (r.cestimp = 11 AND TRUNC(r.festimp)<= trunc(sysdate)))
    AND r.sseguro = s.sseguro
    AND r.nrecibo = m.nrecibo
    AND m.fmovfin is null
    AND m.cestrec = 0 -- Rebuts pendents, Todos
    ORDER BY s.sproduc;

BEGIN
  IF psproduc IS NULL AND pnrecibo is NULL AND psseguro IS NULL THEN
     p_tab_error( sysdate, nvl(pusucobro,f_user), 'F_COBRECIBOS parametros',
                  1,'Parametros incorrectos F_COBRECIBOS', null);
  ELSE

  FOR reg IN tratar LOOP

     IF TRUNC(reg.fefecto) <= TRUNC(nvl(pfcobro,sysdate)) THEN
         error_num := f_movrecibo(reg.nrecibo, 01, NULL, NULL, w_smovrecibo,
                                  w_nliqmen, w_nliqlin, reg.fmovini, reg.ccobban,
                                  reg.cdelega, null, null);

         IF error_num = 0 THEN
            commit;
         ELSE
            p_tab_error( sysdate, nvl(pusucobro,f_user), 'F_COBRECIBOS nrecibo->'||reg.nrecibo,
                         reg.nrecibo,'Error F_MOVRECIBO nº->'||error_num, null);

            nocobrados:=nocobrados+1;
            rollback;
         END IF;

     ELSE
         p_tab_error( sysdate, nvl(pusucobro,f_user), 'F_COBRECIBOS nrecibo->'||reg.nrecibo,
                      reg.nrecibo,'Data cobrament inferior a la de efecte', null);
         error_num := 2;

     END IF;

  END LOOP;

  END IF;

  RETURN(nocobrados);

END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_COBRECIBOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_COBRECIBOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_COBRECIBOS" TO "PROGRAMADORESCSI";
