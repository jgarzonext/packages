--------------------------------------------------------
--  DDL for Function F_DELETE_PRODUCTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DELETE_PRODUCTO" (
   psproduc IN NUMBER,
   pcramo IN NUMBER,
   pcmodali IN NUMBER,
   pccolect IN NUMBER,
   pctipseg IN NUMBER)
   RETURN NUMBER IS
/************************************************************************************************
   F_DELETE_PRODUCTO    Esborra un producte
          Paràmetres :  Pasem el SPRODUC,CRAMO,CMODALI,CCOLECT,CTIPSEG del producte.
                        Retorna un 0 si la funció a anat bé,
                         sino un error: " Error l'insertar a la taula..."
   - Se han añadido las tablas :
              COMISIONPROD, CLAUSUGAR, FORPAGRECPROD,FORPAGRECACTI, FORPAGRECGARAN, DETCARENCIAS,
           GARANZONA, GARANPROTRAMIT, PROPLAPEN, PRODREPREC, PRODTRARESC, NIVELLBONUS,
           HISBONUS, DESBONUS i CODBONUS.
   - Se añade el borrado de la tabla CLAUSUPREG
*************************************************************************************************/
   mens           VARCHAR2(200);
   s_b            NUMBER(4);
   bonus          NUMBER := 0;
BEGIN
   BEGIN
      DELETE      prodtraresc
            WHERE sproduc = psproduc;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 112096;
   END;

   BEGIN
      DELETE      prodreprec
            WHERE sproduc = psproduc;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 112097;
   END;

   BEGIN
      DELETE      proplapen
            WHERE sproduc = psproduc;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 112098;
   END;

   BEGIN
      DELETE      garanprotramit
            WHERE sproduc = psproduc;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 112099;
   END;

   BEGIN
      DELETE      garanzona
            WHERE sproduc = psproduc;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 112100;
   END;

   BEGIN
      DELETE      detcarencias
            WHERE cramo = pcramo
              AND cmodali = pcmodali
              AND ctipseg = pctipseg
              AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 112101;
   END;

   BEGIN
      DELETE      forpagrecgaran
            WHERE cramo = pcramo
              AND cmodali = pcmodali
              AND ctipseg = pctipseg
              AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 112102;
   END;

   BEGIN
      DELETE      forpagrecacti
            WHERE cramo = pcramo
              AND cmodali = pcmodali
              AND ctipseg = pctipseg
              AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 112103;
   END;

   BEGIN
      DELETE      forpagrecprod
            WHERE cramo = pcramo
              AND cmodali = pcmodali
              AND ctipseg = pctipseg
              AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 112104;
   END;

   BEGIN
      DELETE      prodmotmov
            WHERE sproduc = psproduc;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 110088;
   END;

   BEGIN
      DELETE      garanformula
            WHERE cramo = pcramo
              AND cmodali = pcmodali
              AND ctipseg = pctipseg
              AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 110087;
   END;

   BEGIN
      DELETE      parproductos
            WHERE sproduc = psproduc;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 110086;
   END;

   BEGIN
      DELETE      pregunprogaran
            WHERE sproduc = psproduc;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 110085;
   END;

--0031786: NSS: 09/10/2014 Eliminar la tabla SGT_PRODUCTOS. Es una tabla obsoleta que no tiene sentido mantener.
/*
BEGIN
  delete sgt_productos
    where cramo = pcramo and
        cmodali = pcmodali and
        ctipseg = pctipseg and
        ccolect = pccolect;
 EXCEPTION
   when others then
      return 110082;
END;
*/
   BEGIN
      DELETE      pargaranpro
            WHERE cramo = pcramo
              AND cmodali = pcmodali
              AND ctipseg = pctipseg
              AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 110084;
   END;

   BEGIN
      DELETE      pregunpro
            WHERE cramo = pcramo
              AND cmodali = pcmodali
              AND ctipseg = pctipseg
              AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 102426;
   END;

   BEGIN
      DELETE      clausugar
            WHERE cramo = pcramo
              AND cmodali = pcmodali
              AND ctipseg = pctipseg
              AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 112105;
   END;

   BEGIN
      DELETE      clausupreg
            WHERE sclapro IN(SELECT sclapro
                               FROM clausupro
                              WHERE cramo = pcramo
                                AND cmodali = pcmodali
                                AND ctipseg = pctipseg
                                AND ccolect = pccolect);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 112386;
   END;

   BEGIN
      DELETE      clausupro
            WHERE cramo = pcramo
              AND cmodali = pcmodali
              AND ctipseg = pctipseg
              AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 102427;
   END;

   BEGIN
      DELETE      incompgaran
            WHERE cramo = pcramo
              AND cmodali = pcmodali
              AND ctipseg = pctipseg
              AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 112106;
   END;

   BEGIN
      DELETE      garanpro_ulk
            WHERE cramo = pcramo
              AND cmodali = pcmodali
              AND ctipseg = pctipseg
              AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 110083;
   END;

   BEGIN
      DELETE      productos_ulk
            WHERE cramo = pcramo
              AND cmodali = pcmodali
              AND ctipseg = pctipseg
              AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 110081;
   END;

   BEGIN
      DELETE      garanpro
            WHERE cramo = pcramo
              AND cmodali = pcmodali
              AND ctipseg = pctipseg
              AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 102428;
   END;

   BEGIN
      DELETE      activiprod
            WHERE cramo = pcramo
              AND cmodali = pcmodali
              AND ctipseg = pctipseg
              AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 103485;
   END;

   BEGIN
      DELETE      comisionprod
            WHERE cramo = pcramo
              AND cmodali = pcmodali
              AND ctipseg = pctipseg
              AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 112107;
   END;

   BEGIN
      DELETE      forpagpro
            WHERE cramo = pcramo
              AND cmodali = pcmodali
              AND ctipseg = pctipseg
              AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 103654;
   END;

-- Si hi ha bonus
   BEGIN
      SELECT sbonus
        INTO s_b
        FROM codbonus
       WHERE cramo = pcramo
         AND sproduc = psproduc;
   EXCEPTION
      WHEN OTHERS THEN
         bonus := 1;
   END;

   IF bonus = 0 THEN
      BEGIN
         DELETE      nivellbonus
               WHERE sbonush IN(SELECT sbonush
                                  FROM hisbonus
                                 WHERE sbonus = s_b);
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 112087;
      END;

      BEGIN
         DELETE      hisbonus
               WHERE sbonus = s_b;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 112088;
      END;

      BEGIN
         DELETE      desbonus
               WHERE sbonus = s_b;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 112089;
      END;

      BEGIN
         DELETE      codbonus
               WHERE sbonus = s_b
                 AND cramo = pcramo
                 AND sproduc = psproduc;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 112090;
      END;
   END IF;

-- end if
   BEGIN
      DELETE      titulopro
            WHERE cramo = pcramo
              AND cmodali = pcmodali
              AND ctipseg = pctipseg
              AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 103653;
   END;

   BEGIN
      DELETE      productos
            WHERE cramo = pcramo
              AND cmodali = pcmodali
              AND ctipseg = pctipseg
              AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         mens := TO_CHAR(SQLCODE) || ' - ' || SQLERRM;
         --DBMS_OUTPUT.put_line(mens);
         RETURN SQLCODE;
   END;

   RETURN 0;
END f_delete_producto;

/

  GRANT EXECUTE ON "AXIS"."F_DELETE_PRODUCTO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DELETE_PRODUCTO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DELETE_PRODUCTO" TO "PROGRAMADORESCSI";
