--------------------------------------------------------
--  DDL for Package Body PAC_GLOBALES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_GLOBALES" IS
   --
   TYPE rg_globales IS RECORD(
      nom_global     VARCHAR2(50),
      val_global     VARCHAR2(4000)
   );

   --
   TYPE tab_globales IS TABLE OF rg_globales
      INDEX BY VARCHAR2(50);

   --
   g_tb_globales  tab_globales;
   e_global_no_definida EXCEPTION;
   --
   PRAGMA EXCEPTION_INIT(e_global_no_definida, -20001);

   --

   /* ----------------------------------------------------
|| asigna :
||
|| Asigna el valor de la variable
*/
   ----------------------------------------------------
--
   PROCEDURE p_asigna_global(p_global VARCHAR2, p_valor VARCHAR2) IS
      --
      l_nom_global   VARCHAR2(50) := UPPER(p_global);
   --
   BEGIN
      --
      g_tb_globales(l_nom_global).nom_global := l_nom_global;
      g_tb_globales(l_nom_global).val_global := p_valor;
   --
   END p_asigna_global;

--
/* ----------------------------------------------------
|| devuelve :
||
|| Devuelve el valor de la variable en formato VARCHAR2
*/ ----------------------------------------------------
--
   FUNCTION f_obtiene_global(p_global VARCHAR2)
      RETURN VARCHAR2 IS
      --
      l_nom_global   VARCHAR2(50) := UPPER(p_global);
      l_val_global   VARCHAR2(4000);
   --
   BEGIN
      BEGIN
--
/* --------------------------------------
|| Aqui se produce un NO_DATA_FOUND si no
|| existe la variable
*/ --------------------------------------
--
         RETURN g_tb_globales(l_nom_global).val_global;
      --
      EXCEPTION
         WHEN OTHERS THEN
            --WHEN E_GLOBAL_NO_DEFINIDA
             --THEN
              --
            l_val_global := NULL;
            --
            p_asigna_global(l_nom_global, l_val_global);
      --
      END;

      --
      RETURN l_val_global;
   --
   END f_obtiene_global;
END pac_globales;

/

  GRANT EXECUTE ON "AXIS"."PAC_GLOBALES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_GLOBALES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_GLOBALES" TO "PROGRAMADORESCSI";
