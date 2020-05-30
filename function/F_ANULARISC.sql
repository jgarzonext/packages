--------------------------------------------------------
--  DDL for Function F_ANULARISC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ANULARISC" (psseguro IN NUMBER, pnriesgo IN NUMBER,
 pfanulac IN DATE, pmovimi IN NUMBER,pcnotibaja IN NUMBER DEFAULT NULL,pcmotmov IN NUMBER DEFAULT NULL)
RETURN NUMBER AUTHID current_user IS
/************************************************************************
 F_ANULARISC  Anula un riesgo, devuelve 0 si todo ha ido bien
    sino devuelve 103190
 1.- Anulem també les garanties, les clàusules de beneficiari i les clàusules especials d'aquest risc
 2.- Afegim el moviment i modifiquem la taula TARJETAS
 3.- Se parametriza por producto si al dar de baja el riesgo que coincide con el tomador
     se cambia el tomador al siguiente riesgo vigente.
*************************************************************************/
num_err NUMBER;
xsperson NUMBER;
vsproduc NUMBER;
vcobjase NUMBER;
vcont  NUMBER;
vsperson NUMBER;
vcdomici NUMBER;
BEGIN
        SELECT sperson
        INTO xsperson
        FROM RIESGOS
        WHERE sseguro = psseguro
           AND nriesgo = pnriesgo;
 UPDATE RIESGOS
 SET  fanulac = pfanulac,
  nmovimb = pmovimi
 WHERE sseguro = psseguro
  AND nriesgo = pnriesgo
  AND fanulac IS NULL;
 UPDATE TARJETAS
 SET  fbaja = TRUNC(SYSDATE),
  nmovimb = pmovimi
 WHERE sseguro = psseguro
  AND nriesgo = pnriesgo
  AND fbaja IS NULL;
 UPDATE GARANSEG
 SET ffinefe = pfanulac
 WHERE sseguro = psseguro
  AND nriesgo = pnriesgo
  AND ffinefe IS NULL;
 UPDATE CLAUBENSEG
 SET ffinclau = pfanulac
 WHERE sseguro = psseguro
  AND nriesgo = pnriesgo
  AND ffinclau IS NULL;
 UPDATE CLAUSUESP
 SET ffinclau = pfanulac
 WHERE sseguro = psseguro
  AND nriesgo = pnriesgo
  AND ffinclau IS NULL;
        UPDATE ASEGURADOS
        SET ffecfin = pfanulac
        WHERE sseguro = psseguro
           AND sperson = xsperson;
  --sergi motiu de notificació
  IF f_parinstalacion_n('NOTIFIBAJA')=1 THEN
    IF (pcmotmov IS NOT NULL AND pcnotibaja IS NOT NULL ) THEN
      BEGIN
       INSERT INTO notibajaseg
       (sseguro,nmovimi,nriesgo,cmotmov,cnotibaja)
       VALUES (psseguro,pmovimi,pnriesgo,pcmotmov,pcnotibaja);
   EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
    UPDATE notibajaseg SET cmotmov=pcmotmov,cnotibaja=pcnotibaja
    WHERE sseguro = psseguro AND nriesgo =pnriesgo
    AND nmovimi=pmovimi;
      END;
    END IF;
  END IF;

  -- 16-5-2006. Se parametriza por producto.
      -- Si el riesgo es el tomador se cambia el tomador por el
      -- minimo nriesgo activo.
   -- 1 Saber si el objeto asegurado del seguro es una persona.
      SELECT sproduc
      INTO   vsproduc
      FROM   seguros
      WHERE  sseguro = psseguro;

   IF NVL(f_parproductos_v(vsproduc, 'ANULRISCTOM'),0) = 1 THEN
      SELECT cobjase
         INTO   vcobjase
         FROM   productos
         WHERE  sproduc = vsproduc;

         -- 2 Saber si la persona de tomadores es la misma que el riesgo que
         --   estamos anulando. En este caso cambio del tomador
         IF vcobjase = 1
         THEN
            SELECT COUNT(*)
            INTO   vcont
            FROM   tomadores
            WHERE  sseguro = psseguro AND nordtom = 1 AND sperson = xsperson;

            IF vcont > 0
            THEN
               SELECT sperson, cdomici
               INTO   vsperson, vcdomici
               FROM   riesgos
               WHERE  sseguro = psseguro
               AND    nriesgo = (SELECT MIN(nriesgo)
                                 FROM   riesgos
                                 WHERE  sseguro = psseguro AND fanulac IS NULL);

               UPDATE tomadores
                  SET sperson = vsperson,
                   cdomici = vcdomici
                WHERE sseguro = psseguro AND nordtom = 1;
            END IF;
         END IF;
 END IF;



/*
    --SMF : gestion de tarjetas sanitarias ALN
  IF f_parinstalacion_t('TARJET_ALN')='SI' THEN
    num_err:=pac_tarjetcard.f_genera_alta(psseguro,F_USER,NULL);
 IF num_err <> 0 THEN
   RETURN num_err;
 END IF;
  END IF;
*/
  RETURN 0;
EXCEPTION
 WHEN OTHERS THEN
    P_Tab_Error (F_Sysdate, F_USER,
                      'f_anularisc', NULL,
                      'error al anular el riesgo', SQLERRM);
    dbms_output.put_line(SQLERRM);
  RETURN 103190;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_ANULARISC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ANULARISC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ANULARISC" TO "PROGRAMADORESCSI";
