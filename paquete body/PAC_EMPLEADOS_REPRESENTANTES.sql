--------------------------------------------------------
--  DDL for Package Body PAC_EMPLEADOS_REPRESENTANTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_EMPLEADOS_REPRESENTANTES" IS
/******************************************************************************
   NOMBRE:       PAC_EMPLEADOS_REPRESENTANTES
   PROPÓSITO:    Funciones para gestionar empleados y representantes

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        23/10/2012  MDS              1. Creación del package. 0022266: LCOL_P001 - PER - Mantenimiento de promotores, gestores, empleados, coordinador
   2.0        04/10/2013  JDS              2. 0028395: LCOL - PER - No aparece el campo “Compañía” al seleccionar la opción “Externo”
   3.0        08/11/2013  JDS              2. 0027083: LCOL - PER - Revisión Q-Trackers Fase 3A

******************************************************************************/

   /*************************************************************************
     Función que obtiene la lista de empleados
     ...
     param out psquery   : Select
     return              : 0.- OK, 1.- KO
    *************************************************************************/
   FUNCTION f_get_empleados(
      psperson IN NUMBER,
      pctipo IN NUMBER,
      pcsubtipo IN NUMBER,
      pccargo IN NUMBER,
      pccanal IN NUMBER,
      pcidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'PCIDIOMA=' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_EMPLEADOS_REPRESENTANTES.f_get_empleados';
      vcondicion     VARCHAR2(500);
   BEGIN
      -- Control parámetros entrada
      IF pcidioma IS NULL THEN
         RETURN 9000505;   -- Faltan parámetros por informar
      END IF;

      psquery :=
         'SELECT e.sperson,f_nombre(e.sperson, 1) tnombre, e.ctipo, ff_desvalorfijo(800050,'
         || pcidioma || ',e.ctipo) ttipo, e.csubtipo, ff_desvalorfijo(800052,' || pcidioma
         || ',e.csubtipo) tsubtipo, ccargo, ff_desvalorfijo(800056,' || pcidioma
         || ',e.ccargo) tcargo, ccanal, ff_desvalorfijo(800053,' || pcidioma
         || ',e.ccanal) tcanal, e.cusumod, e.fmodifi '
         || ',p.nnumide nnumide, ff_desvalorfijo(672,' || pcidioma || ',p.ctipide) ttipide'
         || ' FROM empleados e, per_personas p ';

      IF psperson IS NOT NULL THEN
         IF vcondicion IS NULL THEN
            vcondicion := ' WHERE e.sperson = ' || psperson;
         ELSE
            vcondicion := vcondicion || ' AND e.sperson = ' || psperson;
         END IF;
      END IF;

      IF pctipo IS NOT NULL THEN
         IF vcondicion IS NULL THEN
            vcondicion := ' WHERE e.ctipo = ' || pctipo;
         ELSE
            vcondicion := vcondicion || ' AND e.ctipo = ' || pctipo;
         END IF;
      END IF;

      IF pcsubtipo IS NOT NULL THEN
         IF vcondicion IS NULL THEN
            vcondicion := ' WHERE e.csubtipo = ' || pcsubtipo;
         ELSE
            vcondicion := vcondicion || ' AND e.csubtipo = ' || pcsubtipo;
         END IF;
      END IF;

      IF pccargo IS NOT NULL THEN
         IF vcondicion IS NULL THEN
            vcondicion := ' WHERE e.ccargo = ' || pccargo;
         ELSE
            vcondicion := vcondicion || ' AND e.ccargo = ' || pccargo;
         END IF;
      END IF;

      IF pccanal IS NOT NULL THEN
         IF vcondicion IS NULL THEN
            vcondicion := ' WHERE e.ccanal = ' || pccanal;
         ELSE
            vcondicion := vcondicion || ' AND e.ccanal = ' || pccanal;
         END IF;
      END IF;

      IF vcondicion IS NULL THEN
         vcondicion := ' WHERE e.sperson = p.sperson ';
      ELSE
         vcondicion := vcondicion || ' AND e.sperson = p.sperson ';
      END IF;

      psquery := psquery || vcondicion;
      vpasexec := 2;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 111715;
   END f_get_empleados;

   /*************************************************************************
     Función que inserta/modifica un registro de empleado
     ...
     return              : 0.- OK, 1.- KO
    *************************************************************************/
   FUNCTION f_set_empleado(
      psperson IN NUMBER,
      pctipo IN NUMBER,
      pcsubtipo IN NUMBER,
      pcargo IN NUMBER,
      pccanal IN NUMBER,
      errores IN OUT t_ob_error)
      RETURN NUMBER IS
      j              NUMBER := 1;
      verr           ob_error;
   BEGIN
      errores := t_ob_error();
      errores.DELETE;

      BEGIN
         INSERT INTO empleados
                     (sperson, ctipo, csubtipo, ccargo, ccanal)
              VALUES (psperson, pctipo, pcsubtipo, pcargo, pccanal);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE empleados
               SET ctipo = pctipo,
                   csubtipo = pcsubtipo,
                   ccargo = pcargo,
                   ccanal = pccanal
             WHERE sperson = psperson;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_EMPLEADOS_REPRESENTANTES.f_set_empleado', 1,
                     'Error Imprevisto insertando datos empleado.', SQLERRM);
         errores.EXTEND;
         verr := ob_error.instanciar(108468, SQLERRM);
         errores(j) := verr;
         RETURN 108468;
   END f_set_empleado;

   /*************************************************************************
     Función que borra un registro de empleado
     ...
     return              : 0.- OK, 1.- KO
    *************************************************************************/
   FUNCTION f_del_empleado(psperson IN NUMBER, pcidioma IN NUMBER, errores IN OUT t_ob_error)
      RETURN NUMBER IS
      i              NUMBER := 1;
      verr           ob_error;
   BEGIN
      errores := t_ob_error();
      errores.DELETE;

      BEGIN
         DELETE FROM productos_empleados
               WHERE sperson = psperson;

         DELETE FROM tipo_empleados
               WHERE sperson = psperson;

         DELETE FROM empleados
               WHERE sperson = psperson;
      EXCEPTION
         WHEN OTHERS THEN
            errores.EXTEND;
            verr := ob_error.instanciar(9904404,
                                        f_axis_literales(9904404, pcidioma) || '  ' || SQLERRM);
            errores(i) := verr;
            RETURN 9904404;   -- Error al borrar de la tabla EMPLEADOS
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1, 'OTHERS : ', SQLERRM);
         errores.DELETE;
         errores.EXTEND;
         verr := ob_error.instanciar(9904404,
                                     f_axis_literales(9904404, pcidioma) || '  ' || SQLERRM);
         errores(i) := verr;
         RETURN 9904404;
   END f_del_empleado;

   /*************************************************************************
     Función que obtiene la lista de representantes
     ...
     param out psquery   : Select
     return              : 0.- OK, 1.- KO
    *************************************************************************/
   FUNCTION f_get_representantes(
      psperson IN NUMBER,
      pctipo IN NUMBER,
      pcsubtipo IN NUMBER,
      ptcompania IN VARCHAR2,
      ptpuntoventa IN VARCHAR2,
      pcidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'PCIDIOMA=' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_EMPLEADOS_REPRESENTANTES.f_get_representantes';
      vcondicion     VARCHAR2(500);
   BEGIN
      -- Control parámetros entrada
      IF pcidioma IS NULL THEN
         RETURN 9000505;   -- Faltan parámetros por informar
      END IF;

      psquery :=
         'SELECT r.sperson,f_nombre(r.sperson, 1) tnombre, r.ctipo, ff_desvalorfijo(800054,'
         || pcidioma || ',r.ctipo) ttipo, r.csubtipo, ff_desvalorfijo(800055,' || pcidioma
         || ',r.csubtipo) tsubtipo, r.tcompania, r.tpuntoventa, r.spercoord, f_nombre(r.spercoord, 1) tspercoord '
         || ',r.cusumod, r.fmodifi ' || ',p.nnumide nnumide, ff_desvalorfijo(672,' || pcidioma
         || ',p.ctipide) ttipide' || ' FROM representantes r , per_personas p ';
      vpasexec := 2;

      IF psperson IS NOT NULL THEN
         IF vcondicion IS NULL THEN
            vcondicion := ' WHERE r.sperson = ' || psperson;
         ELSE
            vcondicion := vcondicion || ' AND r.sperson = ' || psperson;
         END IF;
      END IF;

      IF pctipo IS NOT NULL THEN
         IF vcondicion IS NULL THEN
            vcondicion := ' WHERE r.ctipo = ' || pctipo;
         ELSE
            vcondicion := vcondicion || ' AND r.ctipo = ' || pctipo;
         END IF;
      END IF;

      IF pcsubtipo IS NOT NULL THEN
         IF vcondicion IS NULL THEN
            vcondicion := ' WHERE r.csubtipo = ' || pcsubtipo;
         ELSE
            vcondicion := vcondicion || ' AND r.csubtipo = ' || pcsubtipo;
         END IF;
      END IF;

      IF ptcompania IS NOT NULL THEN
         IF vcondicion IS NULL THEN
            vcondicion := ' WHERE UPPER(r.tcompania) like UPPER(''%' || ptcompania || '%'')';
         ELSE
            vcondicion := vcondicion || ' AND UPPER(r.tcompania) like UPPER(''%' || ptcompania
                          || '%'')';
         END IF;
      END IF;

      IF ptpuntoventa IS NOT NULL THEN
         IF vcondicion IS NULL THEN
            vcondicion := ' WHERE UPPER(r.tpuntoventa) like UPPER(''%' || ptpuntoventa
                          || '%'')';
         ELSE
            vcondicion := vcondicion || ' AND UPPER(r.tpuntoventa) like UPPER(''%'
                          || ptpuntoventa || '%'')';
         END IF;
      END IF;

      IF vcondicion IS NULL THEN
         vcondicion := ' WHERE r.sperson = p.sperson ';
      ELSE
         vcondicion := vcondicion || ' AND r.sperson = p.sperson ';
      END IF;

      psquery := psquery || vcondicion;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 111715;
   END f_get_representantes;

   /*************************************************************************
     Función que inserta/modifica un registro de representante
     ...
     return              : 0.- OK, 1.- KO
    *************************************************************************/
   FUNCTION f_set_representante(
      psperson IN NUMBER,
      pctipo IN NUMBER,
      pcsubtipo IN NUMBER,
      ptcompania IN VARCHAR2,
      ptpuntoventa IN VARCHAR2,
      pspercoord IN NUMBER,
      errores IN OUT t_ob_error)
      RETURN NUMBER IS
      j              NUMBER := 1;
      verr           ob_error;
   BEGIN
      errores := t_ob_error();
      errores.DELETE;

      BEGIN
         INSERT INTO representantes
                     (sperson, ctipo, csubtipo, tcompania, tpuntoventa, spercoord)
              VALUES (psperson, pctipo, pcsubtipo, ptcompania, ptpuntoventa, pspercoord);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE representantes
               SET ctipo = pctipo,
                   csubtipo = pcsubtipo,
                   tcompania = ptcompania,
                   tpuntoventa = ptpuntoventa,
                   spercoord = pspercoord
             WHERE sperson = psperson;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_EMPLEADOS_REPRESENTANTES.f_set_representante', 1,
                     'Error Imprevisto insertando datos representante.', SQLERRM);
         errores.EXTEND;
         verr := ob_error.instanciar(108468, SQLERRM);
         errores(j) := verr;
         RETURN 108468;
   END f_set_representante;

   /*************************************************************************
     Función que borra un registro de representante
     ...
     return              : 0.- OK, 1.- KO
    *************************************************************************/
   FUNCTION f_del_representante(
      psperson IN NUMBER,
      pcidioma IN NUMBER,
      errores IN OUT t_ob_error)
      RETURN NUMBER IS
      i              NUMBER := 1;
      verr           ob_error;
      v_count        NUMBER;
   BEGIN
      errores := t_ob_error();
      errores.DELETE;

      BEGIN
         SELECT COUNT(1)
           INTO v_count
           FROM seguros
          WHERE cpromotor = psperson;

         IF v_count >= 1 THEN
            errores.EXTEND;
            verr := ob_error.instanciar(9904588,
                                        f_axis_literales(9904588, pcidioma) || '  ' || SQLERRM);
            errores(i) := verr;
            RETURN 9904588;   -- Este promotor/representante no se puede borrar,tiene pólizas asignadas.
         END IF;

         DELETE FROM representantes
               WHERE sperson = psperson;
      EXCEPTION
         WHEN OTHERS THEN
            errores.EXTEND;
            verr := ob_error.instanciar(9904411,
                                        f_axis_literales(9904411, pcidioma) || '  ' || SQLERRM);
            errores(i) := verr;
            RETURN 9904411;   -- Error al borrar de la tabla REPRESENTANTES
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1, 'OTHERS : ', SQLERRM);
         errores.DELETE;
         errores.EXTEND;
         verr := ob_error.instanciar(9904411,
                                     f_axis_literales(9904411, pcidioma) || '  ' || SQLERRM);
         errores(i) := verr;
         RETURN 9904411;
   END f_del_representante;
END pac_empleados_representantes;

/

  GRANT EXECUTE ON "AXIS"."PAC_EMPLEADOS_REPRESENTANTES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_EMPLEADOS_REPRESENTANTES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_EMPLEADOS_REPRESENTANTES" TO "PROGRAMADORESCSI";
