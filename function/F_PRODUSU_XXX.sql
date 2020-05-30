--------------------------------------------------------
--  DDL for Function F_PRODUSU_XXX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PRODUSU_XXX" (
   ramo IN NUMBER,
   modali IN NUMBER,
   tipseg IN NUMBER,
   colect IN NUMBER,
   tipo IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/******************** FUNCION QUE RETORNA VALORES 0- NO, 1- SÍ EN FUNCION DEL TIPO DE PROCESO QUE QUEREMOS  *******************/
/*                       1-IMPRESION                                                                                          */
/*                       2-EMISION                                                                                            */
/*                       3-CARTERA                                                                                            */
/*                       4-ESTUDIOS
                         5-Recibos
                         6-Accesible                                                                            */
/******************************************************************************************************************************/
   imprime        NUMBER;
   cartera        NUMBER;
   estudis        NUMBER;
   emite          NUMBER;
   imprecibo      NUMBER;
   accesible      NUMBER;
BEGIN
   IF tipo = 1 THEN
      BEGIN
         SELECT imprimir
           INTO imprime
           FROM prod_usu pu, usuarios u
          WHERE u.cusuari = f_user
            AND pu.cdelega = u.cdelega
            AND pu.cramo = ramo
            AND pu.cmodali = modali
            AND pu.ctipseg = tipseg
            AND pu.ccolect = colect;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            imprime := 1;
         WHEN OTHERS THEN
            imprime := 0;
      END;

      RETURN imprime;
   ELSIF tipo = 2 THEN
      BEGIN
         SELECT emitir
           INTO emite
           FROM prod_usu pu, usuarios u
          WHERE u.cusuari = f_user
            AND pu.cdelega = u.cdelega
            AND pu.cramo = ramo
            AND pu.cmodali = modali
            AND pu.ctipseg = tipseg
            AND pu.ccolect = colect;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            emite := 1;
         WHEN OTHERS THEN
            emite := 0;
      END;

      RETURN emite;
   ELSIF tipo = 3 THEN
      BEGIN
         SELECT cartera
           INTO cartera
           FROM prod_usu, usuarios
          WHERE usuarios.cusuari = f_user
            AND prod_usu.cdelega = usuarios.cdelega
            AND prod_usu.cramo = ramo
            AND prod_usu.cmodali = modali
            AND prod_usu.ctipseg = tipseg
            AND prod_usu.ccolect = colect;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            cartera := 1;
         WHEN OTHERS THEN
            cartera := 0;
      END;

      RETURN cartera;
   ELSIF tipo = 4 THEN
      BEGIN
         SELECT estudis
           INTO estudis
           FROM prod_usu pu, usuarios u
          WHERE u.cusuari = f_user
            AND pu.cdelega = u.cdelega
            AND pu.cramo = ramo
            AND pu.cmodali = modali
            AND pu.ctipseg = tipseg
            AND pu.ccolect = colect;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            estudis := 1;
         WHEN OTHERS THEN
            estudis := 0;
      END;

      RETURN estudis;
   ELSIF tipo = 5 THEN
      BEGIN
         SELECT recibos
           INTO imprecibo
           FROM prod_usu pu, usuarios u
          WHERE u.cusuari = f_user
            AND pu.cdelega = u.cdelega
            AND pu.cramo = ramo
            AND pu.cmodali = modali
            AND pu.ctipseg = tipseg
            AND pu.ccolect = colect;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            imprecibo := 1;
         WHEN OTHERS THEN
            imprecibo := 0;
      END;

      RETURN imprecibo;
   ELSIF tipo = 6 THEN
      BEGIN
         SELECT accesible
           INTO accesible
           FROM prod_usu pu, usuarios u
          WHERE u.cusuari = f_user
            AND pu.cdelega = u.cdelega
            AND pu.cramo = ramo
            AND pu.cmodali = modali
            AND pu.ctipseg = tipseg
            AND pu.ccolect = colect;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            accesible := 1;
         WHEN OTHERS THEN
            accesible := 0;
      END;

      RETURN accesible;
   END IF;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_PRODUSU_XXX" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PRODUSU_XXX" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PRODUSU_XXX" TO "PROGRAMADORESCSI";
