--------------------------------------------------------
--  DDL for Package Body PK_IFSREC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PK_IFSREC" AS
---------------------------------------------------------------------------
   PROCEDURE inicializar(aaproc IN NUMBER, mmproc IN NUMBER) AS
   BEGIN
      vaproc := aaproc;
      vmproc := mmproc;
   END inicializar;

---------------------------------------------------------------------------
   PROCEDURE lee AS
      leido          BOOLEAN := FALSE;
   BEGIN
      IF NOT rec_cv%ISOPEN THEN
         OPEN rec_cv;
      END IF;

      FETCH rec_cv
       INTO regrec;

      IF rec_cv%NOTFOUND THEN
         leido := FALSE;
         regrec.sseguro := -1;

         CLOSE rec_cv;
      ELSE
         leido := TRUE;
         tratamiento;
      END IF;
   END lee;

-------------------------------------------------------------------------
   PROCEDURE tratamiento IS
   BEGIN
-- Inicializar variables
      r := 0;
      codramo := 'IA02';
      num_certificado := NULL;
      poliza_ini := NULL;
      moneda := '???';
      subproducto := 0;
      cod_oficina := 0;
      aport_periodica := 0;
      aport_inicial := 0;

      -- TIpo de recibo
      IF regrec.ctiprec = 3 THEN
         tiprec := 'C';
      ELSE
         tiprec := 'P';
      END IF;

      -- Lectura del numero de certificado
      BEGIN
         SELECT LPAD(polissa_ini, 14, '0'), LPAD(polissa_ini, 6, '0')
           INTO num_certificado, poliza_ini
           FROM cnvpolizas
          WHERE sseguro = regrec.sseguro;

         SELECT LPAD(numpol, 6, '0')
           INTO certificado
           FROM cnvproductos
          WHERE cramo = regrec.cramo
            AND cmodal = regrec.cmodali
            AND ctipseg = regrec.ctipseg
            AND ccolect = regrec.ccolect;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            num_certificado := '00000000000000';
            poliza_ini := '000000';
         WHEN OTHERS THEN
            NULL;
      END;

      IF pk_autom.mensaje = 'SLFCOBRO' THEN
         IF regrec.ccolect = 1 THEN
            IF regrec.antigua < 54675 THEN
               codramo := 'IA01';
               ano := 90;
            ELSE
               codramo := 'IA02';
               ano := 96;
            END IF;
         ELSIF regrec.ccolect = 2 THEN
            codramo := 'IA03';
            ano := 96;
         ELSIF regrec.ccolect = 3 THEN
            IF regrec.antigua < 99620 THEN
               codramo := 'IA04';
               ano := 96;
            ELSE
               codramo := 'IA05';
               ano := 96;
            END IF;
         ELSIF regrec.ccolect = 4 THEN
            codramo := 'IA06';
            ano := 96;
         END IF;

         IF TRUNC(regrec.fefepol) >= TO_DATE('01012003', 'ddmmyyyy') THEN
            codramo := 'IA07';
            ano := 96;
         END IF;
      ELSE   --**tar
         IF regrec.antigua < 5953 THEN
            codramo := 'TAR1';
            ano := 92;
         ELSIF regrec.antigua < 11953 THEN
            codramo := 'TAR2';
            ano := 92;
         ELSIF regrec.antigua < 15370 THEN
            codramo := 'TAR3';
            ano := 92;
         ELSE
            codramo := 'TAR4';
            ano := 92;
         END IF;

         IF regrec.ccolect = 4 THEN
            codramo := 'TAR5';
            ano := 92;
         END IF;

         IF TRUNC(regrec.fefepol) >= TO_DATE('01012003', 'ddmmyyyy') THEN
            codramo := 'TAR6';
            ano := 92;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END tratamiento;

---------------------------------------------------------------------------
   FUNCTION fin
      RETURN BOOLEAN IS
      fins           BOOLEAN := FALSE;
   BEGIN
      IF regrec.sseguro = -1 THEN
         fins := TRUE;
      END IF;

      RETURN fins;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END fin;
---------------------------------------------------------------------------
END pk_ifsrec;

/

  GRANT EXECUTE ON "AXIS"."PK_IFSREC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_IFSREC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_IFSREC" TO "PROGRAMADORESCSI";
