--------------------------------------------------------
--  DDL for Package Body PAC_IAX_OBTENERDATOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_OBTENERDATOS" 
IS
   /******************************************************************************
      NOMBRE:       PAC_IAX_OBTENERDATOS
      PROP脫SITO: Recupera la informaci贸n de la poliza guardada en la base de datos
                     a un nivel independiente.

      REVISIONES:
      Ver        Fecha        Autor             Descripci贸n
      ---------  ----------  ---------------  ------------------------------------
      1.0        16/12/2009   RSC             1. Creaci贸n del package.
      2.0        27/01/2010   RSC             2. 0011735: APR - suplemento de modificaci贸n de capital /prima
      3.0        23/06/2010   RSC             3. 0014598: CEM800 - Informaci贸n adicional en pantallas y documentos
      4.0        06/08/2010   PFA             4. 14598: CEM800 - Informaci贸n adicional en pantallas y documentos
      5.0        09/05/2011   RSC             5. 0018342: LCOL003 - Revalorizaci贸n de capital tipo 'Lista de valores'
      6.0        21/05/2015   YDA             6. Se crea la funci髇 f_evoluprovmatseg_scen y se incluye el parametro pnscenario en f_leeevoluprovmatseg
      7.0        04/06/2015   YDA             7. Se crea la funci髇 f_evoluprovmatseg_minscen
      8.0        03/07/2015   YDA             8. 0036596: Se crea la funci髇 f_get_exclusiones
      9.0        05/08/2015   YDA             9. 0036596: Se crea la funci髇 f_lee_enfermedades
      10.0       10/08/2015   YDA             10.0036596: Se crea la funci髇 f_lee_preguntas
      11.0       12/08/2015   YDA             11.0036596: Se crea la funci髇 f_lee_acciones
   ******************************************************************************/
   e_object_error   EXCEPTION;
   e_param_error    EXCEPTION;

   /*******************************************************************************
    Bug 10690 - Nueva seccion en la consulta de p贸liza. Provisiones por garant铆a.
      param IN sseguro : mesajes de error
      param out mensajes : mesajes de error
      return             : objeto detalle garant铆as
   ********************************************************************************/
   -- Bug 10690 - 16/12/2009 - RSC - APR - Provisiones en productos de cartera (PORTFOLIO)
   FUNCTION f_leeprovisionesgar (
      psseguro   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN t_iax_garantias
   IS
      num_err       NUMBER;
      vpasexec      NUMBER (8)      := 1;
      vparam        VARCHAR2 (500)  := 'psseguro= ' || psseguro;
      vobject       VARCHAR2 (200)
                               := 'PAC_IAX_OBTENERDATOS.f_leeprovisionesgar ';
      v_garantias   t_iax_garantias;
   BEGIN
      --Comprovaci贸 dels par谩metres d'entrada
      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_garantias :=
                  pac_md_obtenerdatos.f_leeprovisionesgar (psseguro, mensajes);
      RETURN v_garantias;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_leeprovisionesgar;

   /*********************************************************************************
    Bug 10690 - Nueva seccion en la consulta de p贸liza. Provision por p贸liza.
      param IN sseguro : mesajes de error
      param out mensajes : mesajes de error
      return             : objeto detalle garant铆as
   **********************************************************************************/
   -- Bug 10690 - 16/12/2009 - RSC - APR - Provisiones en productos de cartera (PORTFOLIO)
   FUNCTION f_leeprovisionpol (psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN ob_iax_datoseconomicos
   IS
      datecon    ob_iax_datoseconomicos;
      num_err    NUMBER;
      vpasexec   NUMBER (8)             := 1;
      vparam     VARCHAR2 (500)         := 'psseguro= ' || psseguro;
      vobject    VARCHAR2 (200)  := 'PAC_IAX_OBTENERDATOS.f_leeprovisionpol ';
   BEGIN
      --Comprovaci贸 dels par谩metres d'entrada
      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      datecon := pac_md_obtenerdatos.f_leeprovisionpol (psseguro, mensajes);
      RETURN datecon;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_leeprovisionpol;

   /*************************************************************************
      Recuperar la informaci贸n de las garantias
      param in pnriesgo  : n煤mero de riesgo
      param out mensajes : mesajes de error
      return             : objeto garantias
   *************************************************************************/
   -- Bug 11735 - RSC - 27/01/2010 - APR - suplemento de modificaci贸n de capital /prima
   FUNCTION f_leegarantias_supl (
      psseguro   IN       NUMBER,
      pnriesgo   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN t_iax_garantias
   IS
      v_garantias   t_iax_garantias;
      num_err       NUMBER;
      vpasexec      NUMBER (8)      := 1;
      vparam        VARCHAR2 (500)  := 'pnriesgo= ' || pnriesgo;
      vobject       VARCHAR2 (200)
                               := 'PAC_IAX_OBTENERDATOS.f_leegarantias_supl ';
   BEGIN
      --Comprovaci贸 dels par谩metres d'entrada
      IF pnriesgo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_garantias :=
         pac_md_obtenerdatos.f_leegarantias_supl (psseguro, pnriesgo,
                                                  mensajes);
      RETURN v_garantias;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_leegarantias_supl;

-- Fin Bug 11735

   /*************************************************************************
      Recuperar la informaci贸n de evoluprovmatseg
      param in sseguro   : n煤mero de seguro
      param in ptablas   : tablas a consultar
      param out mensajes : mesajes de error
      return             : objeto garantias
   *************************************************************************/
   -- Bug 14598 - RSC - 23/06/2010 - CEM800 - Informaci贸n adicional en pantallas y documentos
   -- Bug 14598 - PFA - 06/08/2010 - a帽adir parametro ptablas
   FUNCTION f_leeevoluprovmatseg (
      psseguro     IN       NUMBER,
      ptablas      IN       VARCHAR2,
      pnscenario   IN       NUMBER,
      mensajes     OUT      t_iax_mensajes
   )
      RETURN t_iax_evoluprovmat
   IS
      v_evoluprovmat   t_iax_evoluprovmat;
      num_err          NUMBER;
      vpasexec         NUMBER (8)         := 1;
      vparam           VARCHAR2 (500)
         :=    'psseguro= '
            || psseguro
            || ' ptablas= '
            || ptablas
            || ' pnscenario= '
            || pnscenario;
      vobject          VARCHAR2 (200)
                               := 'PAC_IAX_OBTENERDATOS.f_leeevoluprovmatseg ';
   BEGIN
      --Comprovaci贸 dels par谩metres d'entrada
      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_evoluprovmat :=
         pac_md_obtenerdatos.f_leeevoluprovmatseg (psseguro,
                                                   ptablas,
                                                   pnscenario,
                                                   mensajes
                                                  );
      RETURN v_evoluprovmat;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_leeevoluprovmatseg;

-- Fin Bug 14598

   /*************************************************************************
       Devuelve el capital de una garantia
       param in psseguro   : numero de seguro
       param in pnriesgo   : numero de riesgo
       param in pcgarant   : codigo de la garantia
       param in ptablas    : tablas donde hay que ir a buscar la informaci贸n
       param out mensajes : mesajes de error
       return             : Impporte del capital

       Bug 18342 - 24/05/2011 - AMC
    *************************************************************************/
   FUNCTION f_leecapital (
      psseguro   IN       NUMBER,
      pnriesgo   IN       NUMBER,
      pcgarant   IN       NUMBER,
      ptablas    IN       VARCHAR2,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vicapital   NUMBER;
      ssql        VARCHAR2 (200);
      vpasexec    NUMBER (8)     := 1;
      vparam      VARCHAR2 (100)
         :=    'psseguro='
            || psseguro
            || ' pnriesgo='
            || pnriesgo
            || ' pcgarant='
            || pcgarant
            || ' ptablas='
            || ptablas;
      vobject     VARCHAR2 (200) := 'PAC_IAX_OBTENERDATOS.f_leecapital';
   BEGIN
      IF    psseguro IS NULL
         OR pnriesgo IS NULL
         OR pcgarant IS NULL
         OR ptablas IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vicapital :=
         pac_md_obtenerdatos.f_leecapital (psseguro,
                                           pnriesgo,
                                           pcgarant,
                                           ptablas,
                                           mensajes
                                          );
      -- Bug 18342 - RSC - 09/05/2011 - LCOL003 - Revalorizaci贸n de capital tipo 'Lista de valores'
      --IF vicapital IS NULL THEN
      --   RAISE e_object_error;
      --END IF;
      -- Fin Bug 18342
      RETURN vicapital;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_leecapital;

   /*************************************************************************
     funcion que retorna los cuadros de amortizacion de un prestamo.
     param psseguro : codigo del seguro
     param pnmovimi : codigo del movimiento
     param pctapres : codigo del prestamo
     param mensajes : mensajes registrados en el proceso
     return : t_iax_prestcuadroseg tabla PL con objetos de cuadro de prestamo
     Bug 35712 mnustes
   *************************************************************************/
   FUNCTION f_lee_prestcuadroseg (
      psseguro   IN       seguros.sseguro%TYPE,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN t_iax_prestcuadroseg
   IS
      --
      vobject          VARCHAR2 (200)
                               := 'PAC_IAX_OBTENERDATOS.f_lee_prestcuadroseg';
      vpasexec         NUMBER (8)           := 1;
      vparam           VARCHAR2 (1000)
                                     := 'parametros - psseguro: ' || psseguro;
      prestcuadroseg   t_iax_prestcuadroseg;
   --
   BEGIN
      --
      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      --
      prestcuadroseg :=
                 pac_md_obtenerdatos.f_lee_prestcuadroseg (psseguro, mensajes);
      --
      RETURN prestcuadroseg;
   --
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   --
   END f_lee_prestcuadroseg;

   /*************************************************************************
          Recupera los escenarios de proyeccion de intereses
          param out mensajes : mensajes de error
          return : ref cursor

             11/05/2015   YDA                Mant. Pers. Bug: 34636/202063
   *************************************************************************/
   FUNCTION f_evoluprovmatseg_scen (
      psseguro   IN       NUMBER,
      ptablas    IN       VARCHAR2,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (10)  := NULL;
      vobject    VARCHAR2 (200)
                             := 'PAC_IAX_OBTENERDATOS.f_evoluprovmatseg_scen';
   BEGIN
      cur :=
         pac_md_obtenerdatos.f_evoluprovmatseg_scen (psseguro,
                                                     ptablas,
                                                     mensajes
                                                    );
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_evoluprovmatseg_scen;

   /*************************************************************************
      Recupera el menor escenarios de proyecciones de interes
      param out mensajes : mesajes de error
      return             : number
   *************************************************************************/
   FUNCTION f_evoluprovmatseg_minscen (
      psseguro   IN       NUMBER,
      ptablas    IN       VARCHAR2,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      minesce    NUMBER;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (10)  := NULL;
      vobject    VARCHAR2 (200)
                          := 'PAC_IAX_OBTENERDATOS.f_evoluprovmatseg_minscen';
   BEGIN
      minesce :=
         pac_md_obtenerdatos.f_evoluprovmatseg_minscen (psseguro,
                                                        ptablas,
                                                        mensajes
                                                       );
      RETURN minesce;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_evoluprovmatseg_minscen;

   /*************************************************************************
      Devuelve las exclusiones de una p髄iza
      param in psseguro   : numero de seguro
      param in pnriesgo   : numero de riesgo
      param in ptablas    : tablas donde hay que ir a buscar la informaci髇
      param out mensajes  : mesajes de error
      return              : Tabla de exclusiones

      Bug 36596/208854 - YDA
   *************************************************************************/
   FUNCTION f_get_exclusiones (
      psseguro   IN       NUMBER,
      pnriesgo   IN       NUMBER,
      ptablas    IN       VARCHAR2,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN t_iax_exclusiones
   IS
      v_exclusiones   t_iax_exclusiones := t_iax_exclusiones ();
      num_err         NUMBER;
      vpasexec        NUMBER (8);
      vparam          VARCHAR2 (100)
         :=    'psseguro='
            || psseguro
            || 'pnriesgo='
            || pnriesgo
            || ' ptablas= '
            || ptablas;
      vobject         VARCHAR2 (200)
                                   := 'PAC_IAX_OBTENERDATOS.f_get_exclusiones';
   BEGIN
      IF psseguro IS NULL OR pnriesgo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      v_exclusiones :=
         pac_md_obtenerdatos.f_get_exclusiones (psseguro,
                                                pnriesgo,
                                                ptablas,
                                                mensajes
                                               );
      RETURN v_exclusiones;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_exclusiones;

   /*************************************************************************
      Recuperar la informacion de las enfermedades
   *************************************************************************/
   FUNCTION f_lee_enfermedades (psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_enfermedades_undw
   IS
      v_enfermedades   t_iax_enfermedades_undw := t_iax_enfermedades_undw ();
      vparam           VARCHAR2 (100)          := 'psseguro= ' || psseguro;
      vobject          VARCHAR2 (200)
                                 := 'PAC_IAX_OBTENERDATOS.f_lee_enfermedades';
      vpasexec         NUMBER (8);
      num_err          NUMBER;
   BEGIN
      vpasexec := 1;

      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      v_enfermedades :=
                   pac_md_obtenerdatos.f_lee_enfermedades (psseguro, mensajes);
      RETURN v_enfermedades;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_lee_enfermedades;

   /*************************************************************************
      Recupera la informacion de las preguntas base
   *************************************************************************/
   FUNCTION f_lee_preguntas (psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_basequestion_undw
   IS
      v_question   t_iax_basequestion_undw := t_iax_basequestion_undw ();
      vparam       VARCHAR2 (100)          := 'psseguro= ' || psseguro;
      vobject      VARCHAR2 (200)   := 'PAC_IAX_OBTENERDATOS.f_lee_preguntas';
      vpasexec     NUMBER (8);
      num_err      NUMBER;
   BEGIN
      vpasexec := 1;

      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      v_question := pac_md_obtenerdatos.f_lee_preguntas (psseguro, mensajes);
      RETURN v_question;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_lee_preguntas;

   /*************************************************************************
      Recupera la informacion de las acciones de los asegurados
   *************************************************************************/
   FUNCTION f_lee_acciones(
      psseguro IN NUMBER,
      mensajes OUT t_iax_mensajes
   ) RETURN t_iax_actions_undw IS

     v_actions      t_iax_actions_undw := t_iax_actions_undw();
     vparam          VARCHAR2 (100) :=  'psseguro= '|| psseguro;
     vobject         VARCHAR2 (200) :=  'PAC_IAX_OBTENERDATOS.f_lee_acciones';
     vpasexec        NUMBER (8);
     num_err         NUMBER;
   BEGIN
      vpasexec := 1;
      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      v_actions := pac_md_obtenerdatos.f_lee_acciones(psseguro,mensajes);
      RETURN v_actions;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_lee_acciones;
END pac_iax_obtenerdatos;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_OBTENERDATOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_OBTENERDATOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_OBTENERDATOS" TO "PROGRAMADORESCSI";
