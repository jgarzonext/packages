--------------------------------------------------------
--  DDL for Function F_DEVPROCESO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DEVPROCESO" (psdevolu IN NUMBER, ptuser IN VARCHAR2, pnrecibo OUT NUMBER)
  RETURN number authid current_user IS
-- Fa un recorregut per DEVBANRECIBOS (rebuts tornats pel banc), i els deixa
-- pendents i amb l' estat de Domiciliació retinguda.
  error		NUMBER := 0;
  xsmovrec	NUMBER := 0;
  xnliqmen	NUMBER;
  xcestrec	NUMBER;
  dummy		NUMBER;
  CURSOR cur_devbanrecibos IS
    SELECT nrecibo, do.ccobban
      FROM DEVBANRECIBOS dr, DEVBANORDENANTES do
     WHERE dr.sdevolu = psdevolu
       AND dr.sdevolu = do.sdevolu
       AND dr.nnumnif = do.nnumnif
       AND dr.tsufijo = do.tsufijo
       AND dr.fremesa = do.fremesa;
BEGIN
  pnrecibo:=0;
  FOR r in cur_devbanrecibos
  LOOP
    error := f_situarec(r.nrecibo, f_sysdate, xcestrec);
    IF error = 0 AND xcestrec = 1 THEN
      error := f_movrecibo (r.nrecibo, 0, NULL, NULL, xsmovrec, xnliqmen,
                            dummy, sysdate, r.ccobban,null,null,null);
      IF error = 0 THEN
        BEGIN
          UPDATE recibos
             SET cestimp = 6
           WHERE nrecibo = r.nrecibo;
        EXCEPTION
          WHEN others THEN
            error := 102358;	-- Error al modificar la taula RECIBOS
        END;
      END IF;
    END IF;
    IF error <> 0 THEN
      pnrecibo := r.nrecibo;
      exit;
    END IF;
  END LOOP;
  RETURN error;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DEVPROCESO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DEVPROCESO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DEVPROCESO" TO "PROGRAMADORESCSI";
