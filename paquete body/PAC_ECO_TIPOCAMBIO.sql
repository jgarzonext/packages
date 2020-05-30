--------------------------------------------------------
--  DDL for Package Body PAC_ECO_TIPOCAMBIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_ECO_TIPOCAMBIO" IS
/****************************************************************************
   NOMBRE:      pac_eco_tipocambio
   PROPÓSITO:   Funciones y procedimientos para el tratamieto tipos de cambio.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ----------------------------------
   1.0        05/05/2009   LPS              1. Creación del package.(Copia de Liberty)
   2.0        03/01/2012   JMF              2. 0018423: LCOL705 - Multimoneda
   3.0        11/01/2012   MDS              3. 0018423: LCOL705 - Multimoneda
   4.0        30/01/2012   MDS              3. 0018423: LCOL705 - Multimoneda
   5.0        06/02/2012   JGR              5. 0021115: LCOL_A001-Rebuts no pagats i anticips
   6.0		  19/06/2019	PK				6. IAXIS-4320: Added changes for currency conversion of premium.
****************************************************************************/

   /*************************************************************************
      FUNCTION f_consulta_cambios
      Obtiene el texto asociado a una moneda para un idioma concreto.
      param in p_criterios: Record type t_cambio con los criterios.
      return              : Devuelve una referencia a un cursor ( ya abierto ) con los datos referentes a los cambios de moneda. Se
      le pueden pasar criterios para la selección y se hace con el mismo record, rellenando aquellos que
      deben intervenir en la selección.
                        --> ¡¡¡¡ Al final se debe cerrar el cursor !!!!. <--
      Estructura que devuelve el cursor:
               * moneda_inicial       (eco_tipocambio.cmonori%TYPE)
               * moneda_final         (eco_tipocambio.cmondes%TYPE)
               * fecha                (eco_tipocambio.fcambio%TYPE)
               * tasa                 (eco_tipocambio.itasa%TYPE)
   *************************************************************************/
   FUNCTION f_consulta_cambios(p_criterios IN t_cambio)
      RETURN NUMBER IS
      v_obj          VARCHAR2(100) := 'pac_eco_tipocambio.f_consulta_cambios';
      v_par          VARCHAR2(500)
         := ' mi=' || p_criterios.moneda_inicial || ' mf=' || p_criterios.moneda_final
            || ' fe=' || p_criterios.fecha || ' ta=' || p_criterios.tasa;
      v_pas          NUMBER := 100;
      v_criterios    VARCHAR2(2000);
      v_num_curs     NUMBER;
      v_select       VARCHAR2(4000);

      FUNCTION afegeix_and(p_cadena IN VARCHAR2)
         RETURN VARCHAR2 IS
      BEGIN
         IF TRIM(p_cadena) IS NOT NULL THEN
            RETURN p_cadena || ' and';
         ELSE
            RETURN p_cadena;
         END IF;
      END afegeix_and;
   BEGIN
      v_pas := 105;

      IF p_criterios.moneda_inicial IS NOT NULL THEN
         v_pas := 110;
         v_criterios := afegeix_and(v_criterios) || ' cmonori = ' || CHR(39)
                        || p_criterios.moneda_inicial || CHR(39);
      END IF;

      IF p_criterios.moneda_final IS NOT NULL THEN
         v_pas := 115;
         v_criterios := afegeix_and(v_criterios) || ' cmondes = ' || CHR(39)
                        || p_criterios.moneda_final || CHR(39);
      END IF;

      IF p_criterios.fecha IS NOT NULL THEN
         v_pas := 120;
         v_criterios := afegeix_and(v_criterios) || ' fcambio = to_date(' || CHR(39)
                        || TO_CHAR(p_criterios.fecha, 'dd/mm/yyyy') || CHR(39)
                        || ', ''dd/mm/yyyy'')';
      END IF;

      IF p_criterios.tasa IS NOT NULL THEN
         v_pas := 125;
         v_criterios := afegeix_and(v_criterios) || ' itasa = ' || p_criterios.tasa;
      END IF;

      v_pas := 130;
      v_select :=
         'SELECT cmonori as moneda_inicial, cmondes as moneda_final, to_char(fcambio, ''dd/mm/yyyy'') as fecha, itasa as tasa '
         || 'FROM eco_tipocambio ';

      IF v_criterios IS NOT NULL THEN
         v_pas := 135;
         v_select := v_select || 'where ' || v_criterios;
      END IF;

      v_pas := 140;
      v_select := v_select || ' ORDER BY cmonori asc, cmondes asc, fcambio desc';
      v_pas := 145;
      v_num_curs := DBMS_SQL.open_cursor;
      v_pas := 150;
      DBMS_SQL.parse(v_num_curs, v_select, DBMS_SQL.native);
      --
      v_pas := 155;
      RETURN v_num_curs;
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_obj, v_pas, v_par, SQLERRM || CHR(10) || v_select);
         -- BUG 18423 - MDS - 11/01/2012
         -- si peta que retorne algo
         RETURN NULL;
   END f_consulta_cambios;

/*************************************************************************
   FUNCTION f_datos_cambio_actualizar
   Devuelve los datos asociados a una cambio.
   p_moneda_inicial IN   : código de moneda inicial
   p_moneda_final IN     : código de moneda final
   p_fecha_cambio IN     : fecha del cambio
   return                : Record type t_cambio
*************************************************************************/
   FUNCTION f_datos_cambio_actualizar(
      p_moneda_inicial IN eco_tipocambio.cmonori%TYPE,
      p_moneda_final IN eco_tipocambio.cmondes%TYPE,
      p_fecha_cambio IN eco_tipocambio.fcambio%TYPE)
      RETURN t_cambio IS
      v_obj          VARCHAR2(100) := 'pac_eco_tipocambio.f_datos_cambio_actualizar';
      v_par          VARCHAR2(500)
         := ' mi=' || p_moneda_inicial || ' mf=' || p_moneda_final || ' fe=' || p_fecha_cambio;
      v_pas          NUMBER := 100;
      v_cambio       t_cambio;
   BEGIN
      v_pas := 105;

      --
      SELECT     cmonori, cmondes, fcambio,
                 itasa, cusualt   -- DRA 5-11-2007: Bug Mantis 3356
            INTO v_cambio.moneda_inicial, v_cambio.moneda_final, v_cambio.fecha,
                 v_cambio.tasa, v_cambio.usuario
            FROM eco_tipocambio
           WHERE cmonori = p_moneda_inicial
             AND cmondes = p_moneda_final
             AND fcambio = TRUNC(p_fecha_cambio)
      FOR UPDATE;

      v_pas := 110;
      RETURN v_cambio;
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_obj, v_pas, v_par, SQLERRM);
         -- BUG 18423 - MDS - 11/01/2012
         -- si peta que retorne algo
         RETURN NULL;
   END f_datos_cambio_actualizar;

/*************************************************************************
   PROCEDURE p_nuevo_cambio
   Permite crear una nueva registro de cambio de moneda
   p_cambio IN        : Record type t_cambio
*************************************************************************/
   PROCEDURE p_nuevo_cambio(p_cambio IN t_cambio) IS
      v_obj          VARCHAR2(100) := 'pac_eco_tipocambio.p_nuevo_cambio';
      v_par          VARCHAR2(500)
         := ' mi=' || p_cambio.moneda_inicial || ' mf=' || p_cambio.moneda_final || ' fe='
            || p_cambio.fecha || ' ta=' || p_cambio.tasa;
      v_pas          NUMBER := 100;
   BEGIN
      v_pas := 105;

      -- Antes de borrar el trigger "tipocambio_insert" se encargará poner el valor del usuario y la fecha de inserción.
      -- Se insertan los datos
      INSERT INTO eco_tipocambio
                  (cmonori, cmondes, fcambio,
                   itasa)
           VALUES (p_cambio.moneda_inicial, p_cambio.moneda_final, p_cambio.fecha,
                   p_cambio.tasa);
   --
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         p_tab_error(f_sysdate, f_user, v_obj, v_pas,
                     'Ya existe un registro en eco_tipocambio ' || v_par, SQLERRM);
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_obj, v_pas,
                     'Error registro en eco_codmonedas ' || v_par, SQLERRM);
   END p_nuevo_cambio;

/*************************************************************************
   PROCEDURE p_actualiza_cambio
   Permite actualizar un registro de cambio de moneda
   p_cambio IN        : Record type t_cambio
*************************************************************************/
   PROCEDURE p_actualiza_cambio(p_cambio IN t_cambio) IS
      v_obj          VARCHAR2(100) := 'pac_eco_tipocambio.p_actualiza_cambio';
      v_par          VARCHAR2(500)
         := ' mi=' || p_cambio.moneda_inicial || ' mf=' || p_cambio.moneda_final || ' fe='
            || p_cambio.fecha || ' ta=' || p_cambio.tasa;
      v_pas          NUMBER := 100;
   BEGIN
      v_pas := 105;

      -- Se valida si por fecha se puede modificar o no
      IF f_admite_cambios(p_cambio.moneda_inicial, p_cambio.moneda_final, p_cambio.fecha) THEN
         -- Antes de borrar el trigger "tipocambio_borrar" se encargará de guardar el registro en los históricos
         -- y de poner el usuario y la fecha de modificacion.

         -- Modifico el registro.
         v_pas := 110;

         UPDATE eco_tipocambio
            SET itasa = p_cambio.tasa
          WHERE cmonori = p_cambio.moneda_inicial
            AND cmondes = p_cambio.moneda_final
            AND fcambio = p_cambio.fecha;
      ELSE
         p_tab_error(f_sysdate, f_user, v_obj, v_pas,
                     'No se permite la modificación de tasas con fechas pasadas.', 650068);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_obj, v_pas,
                     'Error registro en eco_codmonedas ' || v_par, SQLERRM);
   END p_actualiza_cambio;

/*************************************************************************
   PROCEDURE p_borra_cambio
   Permite borrar un registro de cambio de moneda
   p_moneda_inicial IN : Código de moneda inicial.
   p_moneda_final IN   : Código de moneda final.
   p_fecha_cambio IN   : Fecha del cambio de moneda.
*************************************************************************/
   PROCEDURE p_borra_cambio(
      p_moneda_inicial IN eco_tipocambio.cmonori%TYPE,
      p_moneda_final IN eco_tipocambio.cmondes%TYPE,
      p_fecha_cambio IN eco_tipocambio.fcambio%TYPE) IS
      v_obj          VARCHAR2(100) := 'pac_eco_tipocambio.p_borra_cambio';
      v_par          VARCHAR2(500)
         := ' mi=' || p_moneda_inicial || ' mf=' || p_moneda_final || ' fe=' || p_fecha_cambio;
      v_pas          NUMBER := 100;
   BEGIN
      v_pas := 105;

      ---- Se valida si por fecha se puede modificar o no
      IF f_admite_cambios(p_moneda_inicial, p_moneda_final, p_fecha_cambio) THEN
         -- Antes de borrar el trigger "tipocambio__borrar" se encargará de guardar el registro en los históricos.

         -- Borro el registro.
         v_pas := 110;

         DELETE      eco_tipocambio
               WHERE cmonori = p_moneda_inicial
                 AND cmondes = p_moneda_final
                 AND fcambio = TRUNC(p_fecha_cambio);
      ELSE
         p_tab_error(f_sysdate, f_user, v_obj, v_pas,
                     'No se permite la eliminación de tasas con fecha pasada.', 650069);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         -- Literales OK. (litarales)
         p_tab_error(f_sysdate, f_user, v_obj, v_pas, 'exit When Others ' || v_par, SQLERRM);
   END p_borra_cambio;

/*************************************************************************
   PROCEDURE p_desbloquear_registro
   Permite desbloquear el registro que se había bloqueado para la actualización
*************************************************************************/
   PROCEDURE p_desbloquear_registro IS
   BEGIN
      ROLLBACK;
   END p_desbloquear_registro;

/*************************************************************************
   FUNCTION f_ultima_modificacion
   Permite conocer el momento en que se realizó la última modificación. Si no se ha modificado nunca       --
   devolverá un nulo.
   p_moneda_inicial IN : Código de moneda inicial.
   p_moneda_final IN   : Código de moneda final.
   p_fecha_cambio IN   : Fecha del cambio de moneda.
   return              : Fecha de la última modificación.
*************************************************************************/
   FUNCTION f_ultima_modificacion(
      p_moneda_inicial IN eco_tipocambio.cmonori%TYPE,
      p_moneda_final IN eco_tipocambio.cmondes%TYPE,
      p_fecha_cambio IN eco_tipocambio.fcambio%TYPE)
      RETURN DATE IS
      v_obj          VARCHAR2(100) := 'pac_eco_tipocambio.f_ultima_modificacion';
      v_par          VARCHAR2(500)
         := ' mi=' || p_moneda_inicial || ' mf=' || p_moneda_final || ' fe=' || p_fecha_cambio;
      v_pas          NUMBER := 100;
      v_fecha        DATE;
   BEGIN
      --
      v_pas := 105;

      SELECT fmodifi
        INTO v_fecha
        FROM eco_tipocambio
       WHERE cmonori = p_moneda_inicial
         AND cmondes = p_moneda_final
         AND fcambio = TRUNC(p_fecha_cambio);

      RETURN v_fecha;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_obj, v_pas, 'exit When Others ' || v_par, SQLERRM);
         -- BUG 18423 - MDS - 11/01/2012
         -- si peta que retorne algo
         RETURN NULL;
   END f_ultima_modificacion;

/*************************************************************************
   FUNCTION f_cambio
   Devuelve la tasa de cambio para dos monedas y una fecha especificadas. La primera moneda será la de     --
   referencia y la segunda será la moneda en la que se quiere convertir el importe.
   p_moneda_inicial IN : Código de moneda inicial.
   p_moneda_final IN   : Código de moneda final.
   p_fecha_cambio IN   : Fecha del cambio de moneda.
   return              : Fecha de la última modificación.
*************************************************************************/
   FUNCTION f_cambio(
      p_moneda_inicial IN eco_tipocambio.cmonori%TYPE,
      p_moneda_final IN eco_tipocambio.cmondes%TYPE,
      p_fecha_cambio IN eco_tipocambio.fcambio%TYPE)
      RETURN eco_tipocambio.itasa%TYPE IS
      v_obj          VARCHAR2(100) := 'pac_eco_tipocambio.f_cambio';
      v_par          VARCHAR2(500)
         := ' mi=' || p_moneda_inicial || ' mf=' || p_moneda_final || ' fe=' || p_fecha_cambio;
      v_pas          NUMBER := 100;
      v_tasa         eco_tipocambio.itasa%TYPE;
      v_tasa1        eco_tipocambio.itasa%TYPE;
      v_tasa2        eco_tipocambio.itasa%TYPE;
      vcmonpas       eco_tipocambio.cmonori%TYPE;
      e_parms        EXCEPTION;
      -- ini BUG 18423 - MDS - 30/01/2012
      -- añadir variables v_dias_cambio, v_fecha_cambio
      v_dias_cambio  NUMBER;
      v_fecha_cambio eco_tipocambio.fcambio%TYPE;
   BEGIN
      v_pas := 105;

      --
      IF p_moneda_inicial IS NULL
         OR p_moneda_final IS NULL
         OR p_fecha_cambio IS NULL THEN
         RAISE e_parms;
      END IF;

      -- ini BUG 18423 - MDS - 30/01/2012
      -- Dias atrás para buscar la tasa de cambio de divisas
      v_dias_cambio := NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                         'DIAS_CAMBIO'),
                           0);
      -- restar dias_cambio a la fecha de cambio inicial
      v_fecha_cambio := p_fecha_cambio - v_dias_cambio;

      -- fin BUG 18423 - MDS - 30/01/2012
      IF p_moneda_inicial = p_moneda_final THEN
         v_pas := 110;
         v_tasa := 1;
      ELSE
         BEGIN
            v_pas := 115;

            SELECT itasa
              INTO v_tasa
              FROM eco_tipocambio
             WHERE cmonori = p_moneda_inicial
               AND cmondes = p_moneda_final
               AND TRUNC(fcambio) = TRUNC(v_fecha_cambio);   --  BUG 18423 - MDS - 30/01/2012 -- IAXIS-4320 PK-19/06/2019

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  v_pas := 120;

                  SELECT 1 / itasa
                    INTO v_tasa
                    FROM eco_tipocambio
                   WHERE cmonori = p_moneda_final
                     AND cmondes = p_moneda_inicial
                     AND TRUNC(fcambio) = TRUNC(v_fecha_cambio);   --  BUG 18423 - MDS - 30/01/2012 -- IAXIS-4320 PK-19/06/2019

               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     v_pas := 125;
                     v_tasa := NULL;
               END;
         END;

         IF v_tasa IS NULL THEN
            -- Se buscan cambios intermedios
            BEGIN
               v_pas := 130;

               SELECT cmondes, itasa
                 INTO vcmonpas, v_tasa1
                 FROM eco_tipocambio
                WHERE cmonori = p_moneda_inicial
                  AND TRUNC(fcambio) = TRUNC(v_fecha_cambio)   --  BUG 18423 - MDS - 30/01/2012 -- IAXIS-4320 PK-19/06/2019
                  AND cmondes = (SELECT cmondes
                                   FROM eco_tipocambio
                                  WHERE cmonori = p_moneda_final
                                    AND TRUNC(fcambio) = TRUNC(v_fecha_cambio));   --  BUG 18423 - MDS - 30/01/2012 -- IAXIS-4320 PK-19/06/2019

               v_pas := 135;

               SELECT itasa
                 INTO v_tasa2
                 FROM eco_tipocambio
                WHERE cmonori = p_moneda_final
                  AND cmondes = vcmonpas
                  AND TRUNC(fcambio) = TRUNC(v_fecha_cambio);   --  BUG 18423 - MDS - 30/01/2012 -- IAXIS-4320 PK-19/06/2019

               v_pas := 140;
               v_tasa := v_tasa1 / v_tasa2;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_pas := 145;

                  SELECT cmondes, itasa
                    INTO vcmonpas, v_tasa1
                    FROM eco_tipocambio
                   WHERE cmonori = p_moneda_final
                     AND fcambio = TRUNC(v_fecha_cambio)   --  BUG 18423 - MDS - 30/01/2012
                     AND cmondes = (SELECT cmondes
                                      FROM eco_tipocambio
                                     WHERE cmonori = p_moneda_inicial
                                       AND TRUNC(fcambio) = TRUNC(v_fecha_cambio));   --  BUG 18423 - MDS - 30/01/2012 -- IAXIS-4320 PK-19/06/2019
                  
                  v_pas := 150;

                  SELECT itasa
                    INTO v_tasa2
                    FROM eco_tipocambio
                   WHERE cmonori = p_moneda_inicial
                     AND cmondes = vcmonpas
                     AND TRUNC(fcambio) = TRUNC(v_fecha_cambio);   --  BUG 18423 - MDS - 30/01/2012 -- IAXIS-4320 PK-19/06/2019

                  v_pas := 155;
                  v_tasa := v_tasa2 / v_tasa1;
            END;
         END IF;
      END IF;

      v_pas := 160;
      RETURN v_tasa;
   EXCEPTION
      WHEN e_parms THEN
         p_tab_error(f_sysdate, f_user, v_obj, v_pas, 'e_parms ' || v_par, SQLERRM);
         RETURN NULL;
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, v_obj, v_pas, 'no data found ' || v_par, SQLERRM);
         -- BUG 18423 - MDS - 11/01/2012
         -- si peta que retorne algo
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_obj, v_pas, 'When others ' || v_par, SQLERRM);
         -- BUG 18423 - MDS - 11/01/2012
         -- si peta que retorne algo
         RETURN NULL;
   END f_cambio;

/*************************************************************************
   PROCEDURE p_guardar_historico
   Guarda el registro que le pasamos en el histórico haciendo las modificaciones que sean oportunas para
   que el histórico sea eficiente.
*************************************************************************/
   PROCEDURE p_guardar_historico(p_registro IN eco_tipocambio%ROWTYPE) IS
      v_obj          VARCHAR2(100) := 'pac_eco_tipocambio.p_guardar_historico';
      v_par          VARCHAR2(500)
         := ' mo=' || p_registro.cmonori || ' md=' || p_registro.cmondes || ' fe='
            || p_registro.fcambio || ' ta=' || p_registro.itasa || ' ua='
            || p_registro.cusualt || ' fa=' || p_registro.falta || ' um='
            || p_registro.cusumod || ' fm=' || p_registro.fmodifi;
      v_pas          NUMBER := 100;
      v_usuario      hiseco_tipocambio.cusuario%TYPE;
      v_fecha_desde  hiseco_tipocambio.fdesde%TYPE;
   BEGIN
      v_pas := 105;

      --
      IF p_registro.fmodifi IS NULL THEN
         v_pas := 110;
         v_usuario := p_registro.cusualt;
         -- DRA 5-11-2007: Bug Mantis 3356
         v_fecha_desde := p_registro.falta;
      ELSE
         v_pas := 115;
         v_usuario := p_registro.cusumod;
         v_fecha_desde := p_registro.fmodifi;
      END IF;

      -- inserto en históricos.
      v_pas := 120;

      INSERT INTO hiseco_tipocambio
                  (cmonori, cmondes, fcambio,
                   itasa, cusuario, fdesde, fhasta)
           VALUES (p_registro.cmonori, p_registro.cmondes, p_registro.fcambio,
                   p_registro.itasa, v_usuario, v_fecha_desde, f_sysdate);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_obj, v_pas, 'error When others ' || v_par, SQLERRM);
   END p_guardar_historico;

/*************************************************************************
   FUNCTION f_admite_cambios
   Esta función me indicará si puedo realizar cambios en los registros seleccionados, ya sean cambios de
   actualización o de borrado.
   p_moneda_inicial IN : Código de moneda inicial.
   p_moneda_final IN   : Código de moneda final.
   p_fecha IN          : Fecha del cambio.
   return              : TRUE o FALSE.
*************************************************************************/
   FUNCTION f_admite_cambios(
      p_moneda_inicial IN eco_tipocambio.cmonori%TYPE,
      p_moneda_final IN eco_tipocambio.cmondes%TYPE,
      p_fecha IN eco_tipocambio.fcambio%TYPE)
      RETURN BOOLEAN IS
      v_obj          VARCHAR2(100) := 'pac_eco_tipocambio.f_admite_cambios';
      v_par          VARCHAR2(500)
                := ' mi=' || p_moneda_inicial || ' mf=' || p_moneda_final || ' fe=' || p_fecha;
      v_pas          NUMBER := 100;
   BEGIN
      v_pas := 105;
      RETURN(TRUNC(p_fecha) >= TRUNC(f_sysdate));
   END f_admite_cambios;

/*************************************************************************
   FUNCTION f_cuantos_registros
   Permite saber cuantos cambios se han informado para una combinación de monedas.
   p_moneda_inicial IN : Código de moneda inicial.
   p_moneda_final IN   : Código de moneda final.
   return              : Número de cambios.
*************************************************************************/
   FUNCTION f_cuantos_registros(
      p_moneda_inicial IN eco_tipocambio.cmonori%TYPE,
      p_moneda_final IN eco_tipocambio.cmondes%TYPE)
      RETURN NUMBER IS
      v_obj          VARCHAR2(100) := 'pac_eco_tipocambio.f_cuantos_registros';
      v_par          VARCHAR2(500) := ' mi=' || p_moneda_inicial || ' mf=' || p_moneda_final;
      v_pas          NUMBER := 100;
      v_cuantos      NUMBER;
   BEGIN
      v_pas := 105;

      SELECT COUNT(*)
        INTO v_cuantos
        FROM eco_tipocambio
       WHERE cmonori = p_moneda_inicial
         AND cmondes = p_moneda_final;

      RETURN v_cuantos;
   END f_cuantos_registros;

/*************************************************************************
   FUNCTION f_importe_cambio
   Devuelve el importe en la moneda especificada a una fecha concreta                                      --
   (DRA 18-06-2008: Cambio el tipo del parametro p_redondear para usarlo en UPDATES                     --
   p_moneda_inicial IN : Código de moneda inicial.
   p_moneda_final IN   : Código de moneda final.
   p_importe IN        : importe en moneda inicial
   p_redondear IN      : '0' --> Si, '1' --> No
   return              : importe en la moneda final
*************************************************************************/
   FUNCTION f_importe_cambio(
      p_moneda_inicial IN eco_tipocambio.cmonori%TYPE,
      p_moneda_final IN eco_tipocambio.cmondes%TYPE,
      p_fecha IN eco_tipocambio.fcambio%TYPE,
      p_importe IN NUMBER,
      p_redondear IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      v_obj          VARCHAR2(100) := 'pac_eco_tipocambio.f_importe_cambio';
      v_par          VARCHAR2(500)
         := ' mi=' || p_moneda_inicial || ' mf=' || p_moneda_final || ' fe=' || p_fecha
            || ' im=' || p_importe || ' re=' || p_redondear;
      v_pas          NUMBER := 100;
      v_cambio       eco_tipocambio.itasa%TYPE;
      v_resultado    NUMBER;
   BEGIN
      v_pas := 105;

      --
      -- BUG 18423 - MDS - 11/01/2012
      -- si p_moneda_inicial=p_moneda_final entonces cambio es 1
      IF (p_moneda_inicial = p_moneda_final) THEN
         v_cambio := 1;
      ELSE
         v_cambio := f_cambio(p_moneda_inicial, p_moneda_final, p_fecha);
      END IF;

      IF p_redondear = 0 THEN
         v_pas := 110;
         v_resultado := p_importe * v_cambio;
      ELSE
         v_pas := 115;
         -- BUG 18423 - MDS - 11/01/2012
         -- convertir p_moneda_final de varchar2 a number
         v_resultado := f_round(p_importe * v_cambio, pac_monedas.f_cmoneda_n(p_moneda_final));
      END IF;

      v_pas := 120;
      RETURN v_resultado;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_obj, v_pas, 'error When others ' || v_par, SQLERRM);
         -- BUG 18423 - MDS - 11/01/2012
         -- si peta que retorne algo
         RETURN NULL;
   END f_importe_cambio;

/*************************************************************************
   FUNCTION f_importe_tasa
   Devuelve el importe según tasa redondeado ya según decimales
   p_importe IN        : Importe
   p_tasa IN           : Tasa
   p_decimal IN        : Decimales
   return              : Importe según tasa
*************************************************************************/
   FUNCTION f_importe_tasa(
      p_importe IN NUMBER,
      p_tasa IN eco_tipocambio.itasa%TYPE,
      p_decimal IN NUMBER)
      RETURN NUMBER IS
      v_obj          VARCHAR2(100) := 'pac_eco_tipocambio.f_importe_tasa';
      v_par          VARCHAR2(500)
                             := ' im=' || p_importe || ' ta=' || p_tasa || ' de=' || p_decimal;
      v_pas          NUMBER := 100;
      v_importe      NUMBER;
   BEGIN
      v_pas := 105;
      v_importe := ROUND((p_importe * p_tasa), p_decimal);
      v_pas := 110;
      RETURN v_importe;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_obj, v_pas, 'error When others ' || v_par, SQLERRM);
         -- BUG 18423 - MDS - 11/01/2012
         -- si peta que retorne algo
         RETURN NULL;
   END f_importe_tasa;

/*************************************************************************
   FUNCTION f_cambio_no_inverso
   Permite detectar si se está intentando dar de alta cambios inversos de tipo
   Ejem:         CMONORI = USD / CMONDES = CLP
           no se permitiría inroducir el inverso
                 CMONORI = CLP / CMONDES = USD
   p_cambio IN         : Record Type t_cambio
   return              : Número de registros en eco_tipocambio.
*************************************************************************/
   FUNCTION f_cambio_no_inverso(p_cambio IN t_cambio)
      RETURN NUMBER IS
      v_obj          VARCHAR2(100) := 'pac_eco_tipocambio.f_cambio_no_inverso';
      v_par          VARCHAR2(500)
                       := ' mi=' || p_cambio.moneda_inicial || ' mf=' || p_cambio.moneda_final;
      v_pas          NUMBER := 100;
      v_dato         NUMBER;
   BEGIN
      v_pas := 105;

      SELECT COUNT(*)
        INTO v_dato
        FROM eco_tipocambio
       WHERE cmonori = p_cambio.moneda_final
         AND cmondes = p_cambio.moneda_inicial;

      v_pas := 110;
      RETURN v_dato;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_obj, v_pas, 'error When others ' || v_par, SQLERRM);
         -- BUG 18423 - MDS - 11/01/2012
         -- si peta que retorne algo
         RETURN NULL;
   END f_cambio_no_inverso;

-- BUG 18423 - 26/10/2011 - JMP - LCOL000 - Multimoneda
/*************************************************************************
   FUNCTION f_fecha_max_cambio
   Devuelve la máxima fecha de cambio existente entre dos divisas que no
   supere una fecha dada
   pmonori             : Código de la moneda origen
   pmondes             : Código de la moneda destino
   pfecha              : Fecha máxima de búsqueda
   return              : Fecha de cambio.
*************************************************************************/
   FUNCTION f_fecha_max_cambio(
      pmonori VARCHAR2,
      pmondes VARCHAR2,
      pfecha DATE DEFAULT f_sysdate)
      RETURN DATE IS
      v_obj          VARCHAR2(100) := 'pac_eco_tipocambio.f_fecha_max_cambio';
      v_par          VARCHAR2(500)
                                 := ' or=' || pmonori || ' de=' || pmondes || ' fe=' || pfecha;
      v_pas          NUMBER := 100;
      v_max_fcambio  DATE;
      v_max_fcambio1 DATE;
      v_max_fcambio2 DATE;
   BEGIN
      v_pas := 105;

      IF pmonori = pmondes THEN
         -- RETURN NULL; -- 5. 0021115: LCOL_A001-Rebuts no pagats i anticips
         RETURN pfecha;   -- 5. 0021115: LCOL_A001-Rebuts no pagats i anticips
      ELSE
         v_pas := 110;

         SELECT MAX(fcambio)
           INTO v_max_fcambio1
           FROM eco_tipocambio
          WHERE cmonori = pmonori
            AND cmondes = pmondes
            AND fcambio <= pfecha;

         v_pas := 115;

         SELECT MAX(fcambio)
           INTO v_max_fcambio2
           FROM eco_tipocambio
          WHERE cmonori = pmondes
            AND cmondes = pmonori
            AND fcambio <= pfecha;
      END IF;

      v_pas := 120;

      IF v_max_fcambio1 IS NOT NULL
         AND v_max_fcambio2 IS NOT NULL THEN
         v_max_fcambio := GREATEST(v_max_fcambio1, v_max_fcambio2);
      ELSE
         IF v_max_fcambio2 IS NOT NULL THEN
            v_max_fcambio := v_max_fcambio2;
         ELSIF v_max_fcambio1 IS NOT NULL THEN
            v_max_fcambio := v_max_fcambio1;
         END IF;
      END IF;

      v_pas := 125;
      RETURN v_max_fcambio;
   END f_fecha_max_cambio;
-- FIN BUG 18423 - 26/10/2011 - JMP - LCOL000 - Multimoneda
END pac_eco_tipocambio;

/

  GRANT EXECUTE ON "AXIS"."PAC_ECO_TIPOCAMBIO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_ECO_TIPOCAMBIO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_ECO_TIPOCAMBIO" TO "PROGRAMADORESCSI";
