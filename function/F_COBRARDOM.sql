--------------------------------------------------------
--  DDL for Function F_COBRARDOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_COBRARDOM" (pcempres IN  NUMBER, psproces IN NUMBER,
                      psmovrec OUT NUMBER)
  RETURN number authid current_user IS
--
-- Cobra els rebuts del procés
--
xsproces   NUMBER;
xsmovrec   NUMBER := 0;
error      NUMBER;
xnliqmen   NUMBER;
dummy	   NUMBER;
CURSOR cur_domicproces IS
  SELECT d.nrecibo, d.fefecto, d.ccobban
    FROM domiciliaciones d
   WHERE sproces = psproces;
BEGIN
  IF (psproces is NULL OR psproces = 0) THEN
    RETURN 101901;    -- Pas incorrecte de paràmetres a la funció
  ELSE
    FOR rec IN cur_domicproces
    LOOP
      xnliqmen := NULL;
      dummy    := NULL;
      error := f_movrecibo(rec.nrecibo, 1, NULL, NULL, xsmovrec, xnliqmen,
                           dummy, rec.fefecto, rec.ccobban ,null,null,null);
      IF error = 0 THEN
-- Actualizamos el nº proceso en domiciliaciones
        BEGIN
          UPDATE domiciliaciones
             SET smovrec = xsmovrec
           WHERE nrecibo = rec.nrecibo
             AND sproces = psproces;
        EXCEPTION
          WHEN others THEN
            RETURN 102922;      -- Error al modificar la taula DOMICILIACIONES
        END;
-- Actualizamos el estado del recibo a "domiciliado"
        BEGIN
          UPDATE recibos
             SET cestimp = 5
           WHERE nrecibo = rec.nrecibo;
        EXCEPTION
          WHEN others THEN
            RETURN 102358;     -- Error al modificar DOMICILIACIONES
        END;
        COMMIT;
      ELSE
        RETURN error;
      END IF;
    END LOOP;
    psmovrec := xsmovrec;
    RETURN 0;
  END IF;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_COBRARDOM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_COBRARDOM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_COBRARDOM" TO "PROGRAMADORESCSI";
