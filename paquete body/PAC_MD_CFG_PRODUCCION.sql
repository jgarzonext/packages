--------------------------------------------------------
--  DDL for Package Body PAC_MD_CFG_PRODUCCION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_CFG_PRODUCCION" AS
/******************************************************************************
   NOMBRE:      PAC_MD_CFG_PRODUCCION
   PROPÓSITO:   Funciones para la consfiguración de las pantallas de producción
                en segunda capa

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        07/01/2007   JAS               1. Creación del package.
   2.0        26/01/2010   DRA               2. 0011583: CRE - Incidencia en modificación de datos de Suplemento
   3.0        27/07/2010   JRH               3. 0015509: CEM - Modificaciones Rentas
   4.0        25/06/2012   DRA               4. 0021927: MDP - TEC - Parametrización producto de Hogar (MHG) - Nueva producción
   5.0        05/07/2012   DRA               5. 0022402: LCOL_C003: Adaptación del co-corretaje
   6.0        27/07/2012   FPG               6. 0023075: LCOL_T010-Figura del pagador
   7.0        03/09/2012   JMF               0022701: LCOL: Implementación de Retorno
******************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;

   /*************************************************************************
      Devuelve si se puede saltar la pantalla de asegurados del flujo de contratación
      param in pObjPol     : Objeto póliza con los datos a evaluar.
      return               : 1 -> Saltar pantalla
                           : 0 -> Mostrar pantalla
                           : Otros -> Error
   *************************************************************************/
   FUNCTION f_skip_asegurados(pobjpol IN OUT ob_iax_detpoliza)
      RETURN NUMBER IS
      vparam         VARCHAR2(500);
      vobjectname    VARCHAR2(500);
      vpasexec       NUMBER(8);
      vcsubpro       NUMBER;
      vnassegs       NUMBER(5);
      vskip          BOOLEAN;
   BEGIN
      vobjectname := 'PAC_MD_CFG_PRODUCCION.F_Skip_Asegurados';
      vparam := 'parámetros - pObjPol';
      vpasexec := 1;

      IF pobjpol IS NULL THEN
         RAISE e_param_error;
      ELSIF pobjpol.tomadores IS NULL THEN
         RAISE e_param_error;
      ELSIF pobjpol.tomadores.COUNT = 0 THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vnassegs := 0;

      FOR i IN pobjpol.tomadores.FIRST .. pobjpol.tomadores.LAST LOOP
         IF pobjpol.tomadores(i).isaseg = 1 THEN
            vnassegs := vnassegs + 1;
         END IF;
      END LOOP;

      vpasexec := 5;

      -- Obtinc el tipus de subproducte (VF 37)
      SELECT p.csubpro
        INTO vcsubpro
        FROM productos p
       WHERE p.sproduc = pobjpol.sproduc;

      IF vcsubpro = 1 THEN   -- Individual   ->   1 risc 1 asegurat
         vskip :=(vnassegs = 1);
      ELSIF vcsubpro = 2 THEN   --Col·lectiu simple   ->   n risc n asegurats
         vskip := FALSE;
      ELSIF vcsubpro = 3 THEN   --Col·lectiu individualitzat   ->   n Polisses 1 risc 1 asegurats
         vskip :=(vnassegs = 1);
      ELSIF vcsubpro = 5 THEN   --Individual 2 cabezas   ->   1 risc 2 asegurats
         vskip :=(vnassegs = 2);
      END IF;

      IF vskip THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 107839;   --Error en els paràmetres d'entrada.
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN -1;
   END f_skip_asegurados;

    -- ini t.7817
    /*************************************************************************
      Devuelve si se puede saltar la pantalla de riesgos del flujo de suplementos
      de preguntas de póliza.
      param in pObjPol     : Objeto póliza con los datos a evaluar.
      return               : 1 -> Saltar pantalla
                           : 0 -> Mostrar pantalla
                           : Otros -> Error
   *************************************************************************/
   FUNCTION f_skip_tarificacion(pobjpol IN OUT ob_iax_detpoliza)
      RETURN NUMBER IS
      vparam         VARCHAR2(500);
      vobjectname    VARCHAR2(500);
      vpasexec       NUMBER(8);
      v_skip         NUMBER := 1;
      v_indice       NUMBER;
   BEGIN
      vobjectname := 'PAC_MD_CFG_PRODUCCION.F_Skip_Tarificacion';
      vparam := 'parámetros - pObjPol';
      vpasexec := 1;

      IF pobjpol.riesgos IS NOT NULL
         AND pobjpol.riesgos.COUNT > 0 THEN
         v_indice := pobjpol.riesgos.FIRST;

         WHILE v_indice IS NOT NULL
          AND v_skip = 1 LOOP
            IF pobjpol.riesgos(v_indice).needtarifar = 1 THEN
               v_skip := 0;
            ELSE
               v_indice := pobjpol.riesgos.NEXT(v_indice);
            END IF;
         END LOOP;
      ELSE
         v_skip := 0;
      END IF;

      RETURN v_skip;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 107839;   --Error en els paràmetres d'entrada.
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN -1;
   END f_skip_tarificacion;

   -- fin 7817

   -- BUG11583:DRA:18/01/2010:Inici
   /*************************************************************************
      Devuelve si se puede saltar la pantalla de seleccion de colectivo del
       flujo de propuestas pendientes de emitir
      param in pObjPol     : Objeto póliza con los datos a evaluar.
      return               : 1 -> Saltar pantalla
                           : 0 -> Mostrar pantalla
                           : Otros -> Error
   *************************************************************************/
   FUNCTION f_skip_certf0(pobjpol IN OUT ob_iax_detpoliza)
      RETURN NUMBER IS
      vparam         VARCHAR2(500) := 'parámetros - pObjPol';
      vobjectname    VARCHAR2(500) := 'PAC_MD_CFG_PRODUCCION.F_Skip_Tarificacion';
      vpasexec       NUMBER(8) := 1;
      v_skip         NUMBER := 1;
      v_numregs      NUMBER;
   BEGIN
      IF pobjpol IS NULL THEN
         RAISE e_param_error;
      END IF;

      SELECT COUNT(1)
        INTO v_numregs
        FROM seguros
       WHERE sseguro = pobjpol.ssegpol;

      IF v_numregs > 0 THEN
         v_skip := 1;
      ELSE
         v_skip := 0;
      END IF;

      RETURN v_skip;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 107839;   --Error en els paràmetres d'entrada.
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN -1;
   END f_skip_certf0;

-- BUG11583:DRA:18/01/2010:Fi

   -- BUG 15509 - 27/07/2010 - JRH - 0015509: CEM - Modificaciones Rentas
   /***************************************************************** en el flujo de contratación********
        Devuelve si se puede saltar la pantalla de beneficiarios
        param in pObjPol     : Objeto póliza con los datos a evaluar.
        return               : 1 -> Saltar pantalla
                             : 0 -> Mostrar pantalla
                             : Otros -> Error
     *************************************************************************/
   FUNCTION f_skip_beneficiarios(pobjpol IN OUT ob_iax_detpoliza)
      RETURN NUMBER IS
      vparam         VARCHAR2(500) := 'parámetros - pObjPol';
      vobjectname    VARCHAR2(500) := 'PAC_MD_CFG_PRODUCCION.f_skip_beneficiarios';
      vpasexec       NUMBER(8) := 1;
      v_skip         NUMBER := 1;
      v_numregs      NUMBER;
   BEGIN
      IF pobjpol IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF NVL(pobjpol.gestion.pcapfall, 0) = 0 THEN
         v_skip := 1;
         pobjpol.riesgos(1).beneficiario := NULL;   --Eliminamos el beneficiario
      ELSE
         v_skip := 0;
      END IF;

      RETURN v_skip;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 107839;   --Error en els paràmetres d'entrada.
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN -1;
   END f_skip_beneficiarios;

-- Fi BUG 15509 - 27/07/2010 - JRH
  /***************************************************************** en el flujo de contratacion********
        Devuelve si se puede saltar la pantalla de comisiones por garantia
        param in pObjPol     : Objeto poliza con los datos a evaluar.
        return               : 1 -> Saltar pantalla
                             : 0 -> Mostrar pantalla
                             : Otros -> Error
     *************************************************************************/
   FUNCTION f_skip_comisiongar(pobjpol IN OUT ob_iax_detpoliza)
      RETURN NUMBER IS
      vparam         VARCHAR2(500) := 'parametros - pObjPol';
      vobjectname    VARCHAR2(500) := 'PAC_MD_CFG_PRODUCCION.f_skip_comisiongar';
      vpasexec       NUMBER(8) := 1;
      v_skip         NUMBER := 1;
      v_numregs      NUMBER;
   BEGIN
      IF pobjpol IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pobjpol.gestion.ctipcom = 91 THEN   --Si es comission por garant?a mostramos la pantalla
         v_skip := 0;
      ELSE
         v_skip := 1;
      END IF;

      RETURN v_skip;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parametros erroneos');
         RETURN 107839;   --Error en els parametres d'entrada.
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN -1;
   END f_skip_comisiongar;

   /********************** en el flujo de contratacion *************************
         Devuelve si se puede saltar la pantalla de inquilinos/avalistas
         param in pObjPol     : Objeto poliza con los datos a evaluar.
         return               : 1 -> Saltar pantalla
                              : 0 -> Mostrar pantalla
                              : Otros -> Error
      *************************************************************************/
   FUNCTION f_skip_inquiaval(pobjpol IN OUT ob_iax_detpoliza)
      RETURN NUMBER IS
      vparam         VARCHAR2(500) := 'parametros - pObjPol';
      vobjectname    VARCHAR2(500) := 'PAC_MD_CFG_PRODUCCION.f_skip_inquiaval';
      vpasexec       NUMBER(8) := 1;
      v_skip         NUMBER := 1;
      v_numregs      NUMBER;
   BEGIN
      IF pobjpol IS NULL THEN
         RAISE e_param_error;
      END IF;

      SELECT COUNT(1)
        INTO v_numregs
        FROM estgaranseg
       WHERE sseguro = pobjpol.sseguro
         AND cgarant = 2385
         AND cobliga = 1;

      IF v_numregs = 0 THEN
         v_skip := 1;
         pobjpol.inquiaval := NULL;
      ELSE
         v_skip := 0;
      END IF;

      RETURN v_skip;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parametros erroneos');
         RETURN 107839;   --Error en els parametres d'entrada.
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN -1;
   END f_skip_inquiaval;

   /********************** en el flujo de contratacion *************************
         Devuelve si se debe mostrar la pantalla del co-corretaje
         param in pObjPol     : Objeto poliza con los datos a evaluar.
         return               : 1 -> Saltar pantalla
                              : 0 -> Mostrar pantalla
                              : Otros -> Error
      *************************************************************************/
   FUNCTION f_skip_corretaje(pobjpol IN OUT ob_iax_detpoliza)
      RETURN NUMBER IS
      vparam         VARCHAR2(500) := 'parametros - pObjPol';
      vobjectname    VARCHAR2(500) := 'PAC_MD_CFG_PRODUCCION.f_skip_corretaje';
      vpasexec       NUMBER(8) := 1;
      v_skip         NUMBER := 1;
      v_cpregun_4780 estpregunpolseg.cpregun%TYPE := 4780;
      v_crespue_4780 estpregunpolseg.crespue%TYPE;
      v_trespue_4780 estpregunpolseg.trespue%TYPE;
      n_registro     NUMBER := 0;
      v_existepreg   NUMBER;
      num_err        NUMBER;
      v_crespue      pregunpolseg.crespue%TYPE;   -- Bug 27539/149064 - APD - 17/07/2013
      salir          EXCEPTION;   -- Bug 27539/149064 - APD - 17/07/2013
   BEGIN
      IF pobjpol IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Bug 24058- XVM- 03/01/2013.Inicio
      IF pobjpol.preguntas IS NOT NULL
         AND pobjpol.preguntas.COUNT > 0 THEN
         vpasexec := 120;

         FOR i IN pobjpol.preguntas.FIRST .. pobjpol.preguntas.LAST LOOP
            vpasexec := 130;

            --IF i = pnregistro THEN
            IF v_cpregun_4780 = pobjpol.preguntas(i).cpregun THEN
               --vpasexec := 140;
               --pcpregun := pac_iax_produccion.poliza.det_poliza.preguntas(i).cpregun;
               vpasexec := 150;
               v_crespue_4780 := pobjpol.preguntas(i).crespue;
               vpasexec := 160;
               v_trespue_4780 := pobjpol.preguntas(i).trespue;
               vpasexec := 170;
               v_existepreg := 1;   -- 1.-Sí existe la pregunta
               EXIT;
            END IF;
         END LOOP;
      END IF;

      --Bug 24058- XVM- 03/01/2013.Fin
      -- Bug 27539/149064 - APD - 17/07/2013 - se añade el IF para diferenciar Nueva Produccion de
      -- Suplemento
      IF pobjpol.nmovimi = 1 THEN   -- Nueva Produccion
         IF NVL(v_crespue_4780, 0) = 0 THEN
            v_skip := 1;
         ELSE
            v_skip := 0;
         END IF;
      ELSE   -- suplemento
         num_err := pac_preguntas.f_get_pregunpolseg(pobjpol.ssegpol, v_cpregun_4780, 'POL',
                                                     v_crespue);

         IF num_err <> 0 THEN
            RAISE salir;
         END IF;

         --  En suplemento, solo mirar el valor de la respuesta si se ha modificado
         IF NVL(v_crespue, 0) <> NVL(v_crespue_4780, 0) THEN
            IF NVL(v_crespue_4780, 0) = 1 THEN
               v_skip := 0;
            ELSE
               v_skip := 1;
            END IF;
         ELSE
            IF NVL(v_crespue, 0) =1 THEN
                v_skip := 0;
            END IF;
         END IF;
      END IF;

      -- fin Bug 27539/149064 - APD - 17/07/2013
      RETURN v_skip;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parametros erroneos');
         RETURN 107839;   --Error en els parametres d'entrada.
      -- Bug 27539/149064 - APD - 17/07/2013
      WHEN salir THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     f_axis_literales(num_err));
         RETURN -1;
      -- fin Bug 27539/149064 - APD - 17/07/2013
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN -1;
   END f_skip_corretaje;

      -- Bug 23075 - FPG - 30/07/2012 - LCOL_T010-Figura del pagador - inicio
   /********************** en el flujo de contratacion *************************
       Devuelve si se debe mostrar la pantalla del pagadores
       param in pObjPol     : Objeto poliza con los datos a evaluar.
       return               : 1 -> Saltar pantalla
                            : 0 -> Mostrar pantalla
                            : Otros -> Error
    *************************************************************************/
   FUNCTION f_skip_pagadores(pobjpol IN OUT ob_iax_detpoliza)
      RETURN NUMBER IS
      vparam         VARCHAR2(500) := 'parametros - pObjPol';
      vobjectname    VARCHAR2(500) := 'PAC_MD_CFG_PRODUCCION.f_skip_pagadores';
      vpasexec       NUMBER(8) := 1;
      v_skip         NUMBER := 1;
      v_crespue      NUMBER;
      num_err        NUMBER;
   BEGIN
      IF pobjpol IS NULL THEN
         RAISE e_param_error;
      ELSIF pobjpol.tomadores IS NULL THEN
         RAISE e_param_error;
      ELSIF pobjpol.tomadores.COUNT = 0 THEN
         RAISE e_param_error;
      END IF;

      v_skip := 1;

      FOR i IN pobjpol.tomadores.FIRST .. pobjpol.tomadores.LAST LOOP
         IF pobjpol.tomadores(i).cexistepagador = 1 THEN
            v_skip := 0;
         END IF;
      END LOOP;

      RETURN v_skip;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parametros erroneos');
         RETURN 107839;   --Error en els parametres d'entrada.
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN -1;
   END f_skip_pagadores;

-- Bug 23075 - FPG - 30/07/2012 - LCOL_T010-Figura del pagador - final

   /********************** en el flujo de contratacion *************************
         Devuelve si se debe mostrar la pantalla del retorno
         param in pObjPol     : Objeto poliza con los datos a evaluar.
         return               : 1 -> Saltar pantalla
                              : 0 -> Mostrar pantalla
                              : Otros -> Error
      *************************************************************************/
   -- ini Bug 0022701 - 03/09/2012 - JMF
   FUNCTION f_skip_retorno(pobjpol IN OUT ob_iax_detpoliza)
      RETURN NUMBER IS
      vparam         VARCHAR2(500) := 'parametros - pObjPol';
      vobjectname    VARCHAR2(500) := 'PAC_MD_CFG_PRODUCCION.f_skip_retorno';
      vpasexec       NUMBER(8) := 1;
      v_skip         NUMBER := 1;
      v_cpregun_4817 estpregunpolseg.cpregun%TYPE := 4817;
      v_crespue_4817 estpregunpolseg.crespue%TYPE;
      v_trespue_4817 estpregunpolseg.trespue%TYPE;
      n_registro     NUMBER := 0;
      v_existepreg   NUMBER;
      num_err        NUMBER;
      v_crespue      pregunpolseg.crespue%TYPE;   -- Bug 27539/149064 - APD - 17/07/2013
      salir          EXCEPTION;   -- Bug 27539/149064 - APD - 17/07/2013
   BEGIN
      IF pobjpol IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Bug 24058- XVM- 03/01/2013.Inicio
      IF pobjpol.preguntas IS NOT NULL
         AND pobjpol.preguntas.COUNT > 0 THEN
         vpasexec := 120;

         FOR i IN pobjpol.preguntas.FIRST .. pobjpol.preguntas.LAST LOOP
            vpasexec := 130;

            --IF i = pnregistro THEN
            IF v_cpregun_4817 = pobjpol.preguntas(i).cpregun THEN
               --vpasexec := 140;
               --pcpregun := pac_iax_produccion.poliza.det_poliza.preguntas(i).cpregun;
               vpasexec := 150;
               v_crespue_4817 := pobjpol.preguntas(i).crespue;
               vpasexec := 160;
               v_trespue_4817 := pobjpol.preguntas(i).trespue;
               vpasexec := 170;
               v_existepreg := 1;   -- 1.-Sí existe la pregunta
               EXIT;
            END IF;
         END LOOP;
      END IF;

      --Bug 24058- XVM- 03/01/2013.Fin

      -- Bug 27539/149064 - APD - 17/07/2013 - se añade el IF para diferenciar Nueva Produccion de
      -- Suplemento
      IF pobjpol.nmovimi = 1 THEN   -- Nueva Produccion
         IF NVL(v_crespue_4817, 0) = 1 THEN
            v_skip := 0;
         ELSE
            v_skip := 1;
         END IF;
      ELSE   -- suplemento
         num_err := pac_preguntas.f_get_pregunpolseg(pobjpol.ssegpol, v_cpregun_4817, 'POL',
                                                     v_crespue);

         IF num_err <> 0 THEN
            RAISE salir;
         END IF;

         --  En suplemento, solo mirar el valor de la respuesta si se ha modificado
         IF NVL(v_crespue, 0) <> NVL(v_crespue_4817, 0) THEN
            IF NVL(v_crespue_4817, 0) = 1 THEN
               v_skip := 0;
            ELSE
               v_skip := 1;
            END IF;
         END IF;
      END IF;

      -- fin Bug 27539/149064 - APD - 17/07/2013
      RETURN v_skip;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parametros erroneos');
         RETURN 107839;   --Error en els parametres d'entrada.
      -- Bug 27539/149064 - APD - 17/07/2013
      WHEN salir THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     f_axis_literales(num_err));
         RETURN -1;
      -- fin Bug 27539/149064 - APD - 17/07/2013
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN -1;
   END f_skip_retorno;
END pac_md_cfg_produccion;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_CFG_PRODUCCION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CFG_PRODUCCION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CFG_PRODUCCION" TO "PROGRAMADORESCSI";
