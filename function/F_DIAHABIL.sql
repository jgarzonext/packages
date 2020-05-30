--------------------------------------------------------
--  DDL for Function F_DIAHABIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DIAHABIL" (poper NUMBER, pfecha DATE, pdiaini NUMBER)
   RETURN DATE IS
   /****************************************************************************
         Ver        Fecha        Autor             Descripción
      ---------  ----------  -------  -------------------------------------
      1.0        XX/XX/XXXX   XXX     1. Creación de la función.
      2.0        31/03/2010   RSC     3. 0014021: CRE - Entran rescates en dias no habiles PPJ Dinámico/PLA Estudiant
   ****************************************************************************/
   fecha          DATE;
   cont           NUMBER;

   FUNCTION mirar_diahabil(fecha DATE)
      RETURN NUMBER IS
      cont           NUMBER(2);
   BEGIN
      -- Bug 20309 - RSC - 20/12/2011 - LCOL_T004-Parametrización Fondos
      --IF TO_NUMBER(TO_CHAR(fecha, 'd')) IN(6, 7) THEN
      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'HABIL_FIN_SEMANA'),
             0) = 0 THEN
         IF TRIM(TO_CHAR(fecha, 'DAY', ' NLS_DATE_LANGUAGE=''AMERICAN'' ')) IN
                                                                        ('SATURDAY', 'SUNDAY') THEN
            RETURN 1;
         END IF;
      END IF;

      -- Fin Bug 20309
      SELECT COUNT(*)
        INTO cont
        FROM planidianohabil
       WHERE dia = TO_NUMBER(TO_CHAR(fecha, 'dd'))
         AND mes = TO_NUMBER(TO_CHAR(fecha, 'mm'))
         AND cestado = 0;

      RETURN cont;
   END mirar_diahabil;

   FUNCTION comprobar_fecha(pfecha DATE, pdiaini NUMBER DEFAULT NULL)
      RETURN DATE IS
      fecha          DATE;
   BEGIN
      fecha := pfecha;

      IF NVL(pdiaini, 0) > 0 THEN
         IF TO_NUMBER(TO_CHAR(fecha, 'mm')) IN(2, 4, 6, 9, 11) THEN
            IF TO_NUMBER(TO_CHAR(LAST_DAY(fecha), 'DD')) < pdiaini THEN
               fecha := LAST_DAY(fecha);
            ELSE
               fecha := TO_DATE(LPAD(TO_CHAR(pdiaini), 2, '0') || TO_CHAR(fecha, 'MMYYYY'),
                                'DDMMYYYY');
            END IF;
         ELSE
            fecha := TO_DATE(LPAD(TO_CHAR(pdiaini), 2, '0') || TO_CHAR(fecha, 'MMYYYY'),
                             'DDMMYYYY');
         END IF;
      END IF;

      RETURN fecha;
   END comprobar_fecha;
BEGIN
   CASE poper
      WHEN 0 THEN   -- Siguente dia habil
         fecha := pfecha + 1;

         WHILE mirar_diahabil(fecha) <> 0 LOOP
            fecha := fecha + 1;
         END LOOP;
      WHEN 1 THEN   -- Ultimo dia habil del mes siguiente
         fecha := ADD_MONTHS(pfecha, 1);
         fecha := comprobar_fecha(fecha, pdiaini);

         WHILE mirar_diahabil(fecha) <> 0 LOOP
            fecha := fecha - 1;
         END LOOP;
      WHEN 2 THEN   -- Cada trimestre.
         fecha := ADD_MONTHS(pfecha, 3);
         fecha := comprobar_fecha(fecha, pdiaini);

         WHILE mirar_diahabil(fecha) <> 0 LOOP
            fecha := fecha + 1;
         END LOOP;
      WHEN 3 THEN   -- Cada año
         fecha := ADD_MONTHS(pfecha, 12);
         fecha := comprobar_fecha(fecha, pdiaini);

         WHILE mirar_diahabil(fecha) <> 0 LOOP
            fecha := fecha + 1;
         END LOOP;
      WHEN 4 THEN   -- Dia habil anterior;
         fecha := pfecha - 1;

         WHILE mirar_diahabil(fecha) <> 0 LOOP
            fecha := fecha - 1;
         END LOOP;
      WHEN 5 THEN   -- Ultimo dia del mes siguiente.
         fecha := ADD_MONTHS(pfecha, 1);
         fecha := comprobar_fecha(fecha, pdiaini);
      WHEN 6 THEN   -- Cada semana.
         fecha := pfecha + 7;
         fecha := comprobar_fecha(fecha, pdiaini);

         WHILE mirar_diahabil(fecha) <> 0 LOOP
            fecha := fecha + 1;
         END LOOP;
      WHEN 7 THEN   -- Dia siguiente
         fecha := pfecha + 1;
      WHEN 8 THEN   -- Primer dia habil del mes siguiente
         fecha := ADD_MONTHS(pfecha, 1);
         fecha := comprobar_fecha(fecha, NVL(pdiaini, 1));

         WHILE mirar_diahabil(fecha) <> 0 LOOP
            fecha := fecha + 1;
         END LOOP;
      WHEN 9 THEN   -- dia fixe de la semana, pdiaini indica dia de la semana. No mira si es habil
         fecha := pfecha + 1;

         WHILE TO_CHAR(fecha, 'D') <> pdiaini LOOP
            fecha := fecha + 1;
         END LOOP;
      WHEN 10 THEN   -- dia fixe de la semana, pdiaini indica dia de la semana. SI mira si es habil
         fecha := pfecha + 1;

         WHILE TO_CHAR(fecha, 'D') <> pdiaini LOOP
            fecha := fecha + 1;
         END LOOP;

         WHILE mirar_diahabil(fecha) <> 0 LOOP
            fecha := fecha + 1;
         END LOOP;
      WHEN 11 THEN   -- suma de dies hàbils
         fecha := pfecha;
         cont := 0;

         IF pdiaini > 0 THEN
            LOOP
               WHILE mirar_diahabil(fecha) <> 0 LOOP
                  fecha := fecha + 1;
               END LOOP;

               IF pdiaini = cont THEN
                  EXIT;
               END IF;

               fecha := fecha + 1;
               cont := cont + 1;
            END LOOP;
         ELSIF pdiaini < 0 THEN   -- Comprovació per número de dies negatiu
            LOOP
               WHILE mirar_diahabil(fecha) <> 0 LOOP
                  fecha := fecha - 1;
               END LOOP;

               IF pdiaini = cont THEN
                  EXIT;
               END IF;

               fecha := fecha - 1;
               cont := cont - 1;
            END LOOP;
         ELSE
            fecha := pfecha;
         END IF;
      WHEN 12 THEN   -- RSC 09/01/2008 El mismo dia si es habil
                     -- y si no el primer habil anterior
         fecha := pfecha;

         WHILE mirar_diahabil(fecha) <> 0 LOOP
            fecha := fecha - 1;
         END LOOP;
      -- Bug 14021 - RSC - 31/03/2010 - CRE - Entran rescates en dias no habiles PPJ Dinámico/PLA Estudiant
   WHEN 13 THEN
         fecha := pfecha;

         WHILE mirar_diahabil(fecha) <> 0 LOOP
            fecha := fecha + 1;
         END LOOP;
      -- Fin Bug 14021
   ELSE
         fecha := NULL;
   END CASE;

   RETURN fecha;
END f_diahabil;

/

  GRANT EXECUTE ON "AXIS"."F_DIAHABIL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DIAHABIL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DIAHABIL" TO "PROGRAMADORESCSI";
