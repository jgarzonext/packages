--------------------------------------------------------
--  DDL for Package Body PK_FSE4507
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PK_FSE4507" AS
PROCEDURE Inicialitza (PANY NUMBER, PPETI_COB NUMBER, PPETI_PAG NUMBER) IS
BEGIN
   vANY := PANY;
   vPETI_COB := PPETI_COB;
   vPETI_PAG := PPETI_PAG;
   CSFISCAB_C := TO_CHAR (PPETI_COB,'FM09999999');
   CSFISCAB_P := TO_CHAR (PPETI_PAG,'FM09999999');
   nseg := 0;
END Inicialitza;
-------
PROCEDURE Llegir AS
BEGIN
   UTL_FILE.get_line (pk_autom.entrada, pk_autom.varlin);
   IF SUBSTR(PK_AUTOM.VARLIN,1,6) = '992059' THEN   ---Es el peu.
      SORTIR := TRUE;
   END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      SORTIR := TRUE;
END Llegir;
---
PROCEDURE Actualitzar AS
BEGIN
   UPDATE fis_fse4500
   SET cestat = -1
   WHERE sfiscab_c = vPETI_COB
   AND sfiscab_p = vPETI_PAG
   AND nanyfisc = vANY
   AND sseguro = TO_NUMBER(vsseguro,'FM0999999999');
   ---
   COMMIT;
END Actualitzar;
---
END PK_FSE4507;

/

  GRANT EXECUTE ON "AXIS"."PK_FSE4507" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_FSE4507" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_FSE4507" TO "PROGRAMADORESCSI";
