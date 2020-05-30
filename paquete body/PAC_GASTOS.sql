--------------------------------------------------------
--  DDL for Package Body PAC_GASTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_GASTOS" AS
---------------------------------------------------------------
----comprobar quants registres hi han d'aquell producte
---------------------------------------------------------------
   FUNCTION f_contar_registros(psproduc IN NUMBER)
      RETURN NUMBER IS
      num            NUMBER := 0;
   BEGIN
      SELECT COUNT(*)
        INTO num
        FROM gastosprod
       WHERE sproduc = psproduc;

      RETURN(num);
   END f_contar_registros;

------------------------------------------------------------------------------------------
-- insersió de registres en la taula gastosprod-------------------------------------------
-------------------------------------------------------------------------------------------
   FUNCTION f_insert_gastos(
      psproduc IN NUMBER,
      pfecha IN DATE,
      ppgastos IN NUMBER,
      pctipapl IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      -- Si hay más registros con el mismo producto, se actualzia la fecha fin de vigencia
      -- con la fecha inicio vigencia del nuevo registro
      IF f_contar_registros(psproduc) > 0 THEN
         -- Se actualiza el registro con el periodo vigente (ffinvig = null)
         BEGIN
            UPDATE gastosprod
               SET ffinvig = pfecha
             WHERE sproduc = psproduc
               --AND finivig <> pfecha
               AND ffinvig IS NULL;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error
                        (f_sysdate, f_user, 'PAC_GASTOS.f_insert_gastos', NULL,
                         'Error no controlado al insertar el registro en la tabla gastosprod',
                         SQLERRM);
               RETURN(SQLERRM);
         END;
      END IF;

      ---insersió-----------
      BEGIN
         INSERT INTO gastosprod
                     (sproduc, finivig, pgastos, ctipapl)
              VALUES (psproduc, pfecha, ppgastos, pctipapl);
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error
                 (f_sysdate, f_user, 'PAC_GASTOS.f_insert_gastos', NULL,
                  'Error no controlado al insertar el primer registro en la tabla gastosprod',
                  SQLERRM);
            RETURN(SQLERRM);
      END;

      RETURN(0);
   END f_insert_gastos;

----------------------------------------------------------------------------------------------------------
-- modificar registro en la tabla gastosprod -------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
   FUNCTION f_modificar_gastos(
      psproduc IN NUMBER,
      pfecha IN DATE,
      ppgastos IN NUMBER,
      pctipapl IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      IF f_contar_registros(psproduc) = 1 THEN
         -- Se está modificando el único registro que hay
         -- Se ha podido modificar: la Fecha, el % Gastos y Tipo de aplicación
         BEGIN
            UPDATE gastosprod
               SET finivig = pfecha,
                   pgastos = ppgastos,
                   ctipapl = pctipapl
             WHERE sproduc = psproduc;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error
                       (f_sysdate, f_user, 'PAC_GASTOS.f_modificar_gastos', NULL,
                        'Error no controlado al modificar el registro en la tabla gastosprod',
                        SQLERRM);
               RETURN(SQLERRM);
         END;
      ELSIF f_contar_registros(psproduc) > 1 THEN
         -- Hay más de un registro y se está modificando
         -- Se ha podido modificar: el % Gastos
         BEGIN
            UPDATE gastosprod
               SET pgastos = ppgastos
             WHERE sproduc = psproduc
               AND finivig = pfecha
               AND ffinvig IS NULL;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error
                       (f_sysdate, f_user, 'PAC_GASTOS.f_modificar_gastos', NULL,
                        'Error no controlado al modificar el registro en la tabla gastosprod',
                        SQLERRM);
               RETURN(SQLERRM);
         END;
      END IF;

      RETURN(0);
   END f_modificar_gastos;

----------------------------------------------------------------------------------------------------------
-- borrar registro en la tabla gastosprod ----------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
   FUNCTION f_borrar_gastos(
      psproduc IN NUMBER,
      pfecha IN DATE,
      ppgastos IN NUMBER,
      pctipapl IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      DELETE FROM gastosprod
            WHERE sproduc = psproduc
              AND finivig = pfecha;

      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_DURPERIODOPROD.f_borrar_durperiodoprod', NULL,
                     'Error no controlado al borrar el registro en la tabla durperiodoprod',
                     SQLERRM);
         RETURN(SQLERRM);
   END f_borrar_gastos;

---------------------------------------------------------------------------------
-- buscar el nom de l'aplicació--------------------------------------------------
---------------------------------------------------------------------------------
   FUNCTION f_buscar_nomaplica(
      pcvalor IN NUMBER,
      pcatribu IN NUMBER,
      pcidioma IN NUMBER,
      pnomaplica IN OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      SELECT tatribu
        INTO pnomaplica
        FROM detvalores
       WHERE cvalor = pcvalor
         AND catribu = pcatribu
         AND cidioma = pcidioma;

      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(SQLERRM);
   END f_buscar_nomaplica;

-----------------------------------------------------------------------------------------------------------
-- para un sseguro y fecha determinada devuelve el porcentaje de gastos aplicado a la fecha solicitada ----
-----------------------------------------------------------------------------------------------------------
   FUNCTION ff_gastos_producto(psproduc IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
      v_gastos       NUMBER(6, 2);
   BEGIN
      SELECT NVL(pgastos, 0)
        INTO v_gastos
        FROM gastosprod
       WHERE sproduc = psproduc
         AND finivig <= pfecha
         AND(ffinvig > pfecha
             OR ffinvig IS NULL);

      RETURN(v_gastos);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error
                    (f_sysdate, f_user, 'PAC_GASTOS.Ff_gastos_producto', NULL,
                     'Error no controlado al buscar porcentaje de gastos a nivel de producto',
                     SQLERRM);
         RETURN(NULL);
   END ff_gastos_producto;

-----------------------------
-- Funcion f_gastos_seguro --
-----------------------------
   FUNCTION ff_gastos_seguro(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pfecha IN DATE DEFAULT f_sysdate)
      RETURN NUMBER IS
      v_sproduc      NUMBER(6);
      v_ctipapl      NUMBER(1);
      v_fefecto      DATE;
      v_fecha        DATE;
      v_ssegpol      NUMBER;
      v_fcaranu      DATE;
   BEGIN
      -- Buscamos la fecha de efecto y código del producto para un seguro (póliza) determinado
      IF ptablas = 'EST' THEN
         BEGIN
            SELECT sproduc, fefecto, ssegpol
              INTO v_sproduc, v_fefecto, v_ssegpol
              FROM estseguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_GASTOS.Ff_gastos_seguro', NULL,
                           'Error no controlado al buscar sproduc de la tabla estseguros',
                           SQLERRM);
               RETURN(NULL);
         END;
      ELSIF ptablas = 'SOL' THEN
         BEGIN
            SELECT sproduc, falta
              INTO v_sproduc, v_fefecto
              FROM solseguros
             WHERE ssolicit = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_GASTOS.Ff_gastos_seguro ', NULL,
                           'Error no controlado al buscar sproduc de la tabla solseguros',
                           SQLERRM);
               RETURN(NULL);
         END;
      ELSE
         BEGIN
            SELECT sproduc, fefecto, fcaranu
              INTO v_sproduc, v_fefecto, v_fcaranu
              FROM seguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_GASTOS.f_gastos_seguro ', NULL,
                           'Error no controlado al buscar sproduc de la tabla seguros',
                           SQLERRM);
               RETURN(NULL);
         END;
      END IF;

      -- Se busca el tipo de aplicacion de gastos definido en el producto
      BEGIN
         SELECT DISTINCT ctipapl
                    INTO v_ctipapl
                    FROM gastosprod
                   WHERE sproduc = v_sproduc;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_GASTOS.f_gastos_seguro ', NULL,
                        'Error no controlado al buscar CTIPAPL de la tabla GASTOSPROD',
                        SQLERRM);
            RETURN(NULL);
      END;

      --DBMS_OUTPUT.put_line('ctipapl =' || v_ctipapl);
      IF v_ctipapl = 1 THEN   -- Aplicación sólo en nueva producción
         v_fecha := v_fefecto;   -- Fecha efecto de la póliza (seguro)
      ELSIF v_ctipapl = 2 THEN   -- Aplicación también en cartera (primas fraccionadas)
         v_fecha := f_sysdate;   -- Fecha actual
      ELSIF v_ctipapl = 3 THEN   -- Aplicación también en cartera (primas fraccionadas)
         IF ptablas = 'EST' THEN
            --DBMS_OUTPUT.put_line('entramos en tablas est');
            BEGIN
               SELECT MAX(fefecto)
                 INTO v_fecha
                 FROM movseguro
                WHERE sseguro = v_ssegpol
                  AND cmovseg = 2
                  AND fefecto <= pfecha;

               IF v_fecha IS NULL THEN
                  v_fecha := v_fefecto;
               END IF;
            -- DBMS_OUTPUT.put_line('despues de la select');
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error
                        (f_sysdate, f_user, 'PAC_GASTOS.f_gastos_seguro ', NULL,
                         'Error no controlado al buscar fefecto máxima en la tabla movseguro',
                         SQLERRM);
                  RETURN(NULL);
            END;
         -- DBMS_OUTPUT.put_line('v_fecha =' || v_fecha);
         ELSIF ptablas = 'SOL' THEN
            v_fecha := v_fefecto;
         ELSE
            IF pfecha = v_fcaranu THEN
               -- si es cartera utilizamos la fecha de efecto (que será la fcaranu de la póliza)
               v_fecha := pfecha;
            ELSE
               BEGIN
                  SELECT MAX(fefecto)
                    INTO v_fecha
                    FROM movseguro
                   WHERE sseguro = psseguro
                     AND cmovseg = 2
                     AND fefecto <= pfecha;

                  IF (v_fecha IS NULL)
                     OR(v_fecha < v_fefecto) THEN
                     v_fecha := v_fefecto;
                  END IF;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     v_fecha := v_fefecto;
                  WHEN OTHERS THEN
                     p_tab_error
                        (f_sysdate, f_user, 'PAC_GASTOS.f_gastos_seguro', NULL,
                         'Error no controlado al buscar fefecto maxima en la tabla movseguro',
                         SQLERRM);
                     RETURN(NULL);
               END;
            END IF;
         END IF;
      END IF;

      -- DBMS_OUTPUT.put_line('v_fecha final =' || v_fecha);
      IF v_sproduc IS NOT NULL
         AND v_fecha IS NOT NULL THEN
         RETURN(ff_gastos_producto(v_sproduc, v_fecha));
      ELSE
         RETURN(NULL);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_GASTOS.f_gastos_seguro ', NULL,
                     'Error no controlado ', SQLERRM);
         RETURN(NULL);
   END ff_gastos_seguro;

--------------------------------------------------------------------------------------------------------------------------
-- Abre el periodo anterior, si existe, es decir, actualiza la fecha fin vigencia (ffinvig = null) del periodo anterior --
--------------------------------------------------------------------------------------------------------------------------
   FUNCTION f_abrir_periodo_anterior(psproduc IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
      num            NUMBER;
   BEGIN
       -- Se mira si no queda ningun registro con fecha fin a null, lo que quiere decir que se han
      -- borrado todos los registros de un periodo. Si es así, se debe abrir el periodo anterior
      -- si es que hay, es decir, si no se ha borrado el único período que existia
      num := 0;

      SELECT COUNT(*)
        INTO num
        FROM gastosprod
       WHERE sproduc = psproduc
         AND ffinvig IS NULL;

      -- Si hay registros con ffinvig = null (num <> 0) no se debe abrir el periodo anterior
      -- pues aun existen más registros del periodo vigente
      IF num = 0
         AND f_contar_registros(psproduc) > 0 THEN   -- se han borrado todos los registros de un periodo,
                                                     --por lo que se debe abrir el periodo anterior, si hay
         UPDATE gastosprod
            SET ffinvig = NULL
          WHERE sproduc = psproduc
            AND ffinvig = pfecha;
      END IF;

      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_DURPERIODOPROD.f_abrir_periodo_anterior', NULL,
                     'Error no controlado al abrir el periodo anterior', SQLERRM);
         RETURN(SQLERRM);
   END f_abrir_periodo_anterior;
END pac_gastos;

/

  GRANT EXECUTE ON "AXIS"."PAC_GASTOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_GASTOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_GASTOS" TO "PROGRAMADORESCSI";
