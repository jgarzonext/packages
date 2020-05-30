--------------------------------------------------------
--  DDL for Package Body PK_GESTION_COMISIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PK_GESTION_COMISIONES" IS
   FUNCTION obtener_producto_comisiones(
      pspro IN NUMBER,
      cgii OUT NUMBER,
      cgee OUT NUMBER,
      cgei OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      SELECT pgasint, pgaexex, pgaexin
        INTO cgii, cgee, cgei
        FROM productos
       WHERE sproduc = pspro;

      RETURN(0);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN(1);
   END;

   FUNCTION insertar_campos(psesion IN NUMBER, pparam IN VARCHAR2, pvalor IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      -- I - JLB - OTIMIZA
      RETURN pac_sgt.put(psesion, pparam, pvalor);
   /*
      INSERT INTO sgt_parms_transitorios
                  (sesion, parametro, valor)
           VALUES (psesion, pparam, pvalor);
      RETURN(0);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         UPDATE sgt_parms_transitorios
            SET valor = pvalor
          WHERE sesion = psesion
            AND parametro = pparam;

         RETURN 0;
      WHEN OTHERS THEN
         -- DBMS_OUTPUT.put_line(SQLERRM);
         RETURN -9;
    */-- F - JLB - OTIMIZA
   END;

   PROCEDURE comisiones(
      pempr IN NUMBER,
      pfini IN NUMBER,
      pffin IN NUMBER,
      pspro IN NUMBER,
      pcgii OUT NUMBER,
      pcgei OUT NUMBER,
      pcgee OUT NUMBER) IS
      nerror         NUMBER;
      psesion        NUMBER;
      cgii           NUMBER(9, 6);
      cgee           NUMBER(9, 6);
      cgei           NUMBER(9, 6);

      CURSOR difcomisiones IS
         SELECT ccampo, clave
           FROM rentasformula
          WHERE sproduc = pspro;

      presultado     NUMBER;
      pformula       VARCHAR2(2000);
   BEGIN
      nerror := pk_gestion_comisiones.obtener_producto_comisiones(pspro, cgii, cgee, cgei);

      IF nerror = 0 THEN
         SELECT sgt_sesiones.NEXTVAL
           INTO psesion
           FROM DUAL;

         nerror := pk_gestion_comisiones.insertar_campos(psesion, 'SESION', psesion);
         --para calcular comisiones
         nerror := pk_gestion_comisiones.insertar_campos(psesion, 'CEMPRE', pempr);
         nerror := pk_gestion_comisiones.insertar_campos(psesion, 'FECINI', pfini);
         nerror := pk_gestion_comisiones.insertar_campos(psesion, 'FECFIN', pffin);
         nerror := pk_gestion_comisiones.insertar_campos(psesion, 'SPRODUC', pspro);

         IF nerror = 0 THEN
            FOR comision IN difcomisiones LOOP
               IF comision.ccampo = 'COMCGII' THEN
                  IF cgii IS NULL THEN
                     cgii := 0;
                  END IF;

                  nerror := pk_gestion_comisiones.insertar_campos(psesion, 'GIII', cgii);
               END IF;

               IF comision.ccampo = 'COMCGEI' THEN
                  IF cgei IS NULL THEN
                     cgei := 0;
                  END IF;

                  nerror := pk_gestion_comisiones.insertar_campos(psesion, 'PGAEXIN', cgei);
               END IF;

               IF comision.ccampo = 'COMCGEE' THEN
                  IF cgee IS NULL THEN
                     cgee := 0;
                  END IF;

                  nerror := pk_gestion_comisiones.insertar_campos(psesion, 'PGAEXEX', cgee);
               END IF;

               SELECT formula
                 INTO pformula
                 FROM sgt_formulas
                WHERE clave = comision.clave;

               --evaluación de la fórmula
               presultado := pk_formulas.eval(pformula, psesion);

               IF comision.ccampo = 'COMCGII' THEN
                  pcgii := presultado;
               END IF;

               IF comision.ccampo = 'COMCGEI' THEN
                  pcgei := presultado;
               END IF;

               IF comision.ccampo = 'COMCGEE' THEN
                  pcgee := presultado;
               END IF;
            END LOOP;

             --borro los valores de los parámetros
             -- I - JLB - OPTIMI
            -- DELETE FROM sgt_parms_transitorios
            --       WHERE sesion = psesion;
            nerror := pac_sgt.del(psesion);
         -- F - JLB - OPTIMI
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF difcomisiones%ISOPEN THEN
            CLOSE difcomisiones;
         END IF;

         ROLLBACK;
         --DBMS_OUTPUT.put_line(SQLERRM);
         nerror := SQLCODE;
   END comisiones;
END pk_gestion_comisiones;

/

  GRANT EXECUTE ON "AXIS"."PK_GESTION_COMISIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_GESTION_COMISIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_GESTION_COMISIONES" TO "PROGRAMADORESCSI";
