--------------------------------------------------------
--  DDL for Package Body PAC_MD_BASESTECNICAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_BASESTECNICAS" AS
/*****************************************************************************
   NAME:       PAC_MD_BASESTECNICAS
   PURPOSE:   Funciones de obtención de las bases técnicas de una póliza

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        14/12/2009   APD             1. Creación del package.
   2.0        29/12/2009   APD             2. Bug 12485 - se añade el campo fvencimcapgar en el objeto OB_IAX_BASESTECNICAS
   4.0       03/01/2010    JRH           16. 0012499: CEM - ESCUT CONSTANT 95 - Desdoblar en dos productos: préstamos personales e hipotecarios
   5.0       03/01/2010    JRH           5. 0012342: Mostrar bases técnicas
   6.0       10/02/2010    JRH           6. 0013100: Verificación migración CRS
   7.0       30/07/2010    JRH           7. 0015587: CEM - Rentas - Interés mínimo en consulta póliza
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   mensajes       t_iax_mensajes := NULL;
   gidioma        NUMBER := pac_md_common.f_get_cxtidioma;

     ------- Funciones internes
   --JRH 14/12/2009
     /*************************************************************************
        Obtiene un objeto del tipo OB_IAX_BASESTECNICAS con las bases técnicas
        param in psseguro  : póliza
        param in pnriesgo  : riesgo (si pnriesgo IS NULL, se mostraron todos)
        param in pnmovimi     : pnmovimi
        param out          : Fecha revisión, fecha revisión anterior, interés actual, interés inicial.
        return             : 0 si todo va bien o  1.
     *************************************************************************/
   FUNCTION f_obtdatosini(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pfecharevi OUT DATE,
      pfechareviant OUT DATE,
      ppinttec OUT NUMBER,
      pninttec OUT NUMBER,
      pintpolmin OUT NUMBER,
      ptabla IN VARCHAR2 DEFAULT 'SEG')
      RETURN NUMBER IS
      vsproduc       productos.sproduc%TYPE;
      vfefecto       seguros.fefecto%TYPE;
      vtipo          NUMBER;
      vfecreviant    seguros_aho.frevant%TYPE;
      vfecrevi       seguros_aho.frevisio%TYPE;
      vndurper       seguros_aho.ndurper%TYPE;
      vnduraci       seguros.nduraci%TYPE;
      vfecha         DATE;
   BEGIN
      IF ptabla = 'EST' THEN
         SELECT sproduc, fefecto, nduraci
           INTO vsproduc, vfefecto, vnduraci
           FROM estseguros
          WHERE sseguro = psseguro;

         SELECT frevant, frevisio, ndurper
           INTO vfecreviant, vfecrevi, vndurper
           FROM estseguros_aho
          WHERE sseguro = psseguro;

         vfecha := f_sysdate;
      ELSE
         SELECT sproduc, fefecto, nduraci
           INTO vsproduc, vfefecto, vnduraci
           FROM seguros
          WHERE sseguro = psseguro;

         SELECT frevant, frevisio, ndurper
           INTO vfecreviant, vfecrevi, vndurper
           FROM seguros_aho
          WHERE sseguro = psseguro;

         SELECT fefecto
           INTO vfecha
           FROM movseguro
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi;
      END IF;

      vtipo := f_es_renova(psseguro, vfecha);

      IF vtipo = 0 THEN
         vtipo := 4;   -- Interés Garatizado en el periodod de Renovación
      ELSE
         vtipo := 3;   --Interés Garatizado en el periodod de Alta
      END IF;

      pfechareviant := vfecreviant;
      pfecharevi := vfecrevi;
      -- Bug 13100 - JRH - 10/02/2010 - 0013100: Verificar migración CRS --> Ponemos f_sysdate
      ppinttec := pac_inttec.ff_int_seguro(ptabla, psseguro, f_sysdate);
      -- Fi Bug 13100
      pninttec := pac_inttec.ff_int_producto(vsproduc, vtipo, NVL(vfecreviant, vfefecto),
                                             NVL(vndurper, 0));   --Suponemos por periodo
      -- Bug 15587 - JRH - 30/07/2010 - 0015587: CEM - Rentas - Interés mínimo en consulta póliza. Se supone que es a fecha efecto cte. para toda la vida de la póliza.
      pintpolmin := pac_inttec.ff_int_producto(vsproduc, 1, vfefecto, NVL(vndurper, 0));
      -- Fi Bug 15587 - JRH - 30/07/2010
      RETURN 0;
   EXCEPTION
      -- Bug 12499 - JRH - 30/12/2009 - Si no hay registro en SEGUROS_AHO no pasa nada
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      -- Fi Bug 12499 - JRH - 30/12/2009
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MD_BASESTECNICAS.f_obtDatosIni', 1,
                     'psseguro = ' || psseguro || ';pnmovimi = ' || pnmovimi || ';ptabla = '
                     || ptabla,
                     SQLERRM);
         RETURN 1;
   END f_obtdatosini;

   --JRH 14/12/2009
   /*************************************************************************
      Obtiene un objeto del tipo OB_IAX_BASESTECNICAS con las bases técnicas
      param in psseguro  : póliza
      param in pnriesgo  : riesgo (si pnriesgo IS NULL, se mostraron todos)
      param in pnmovimi     : pnmovimi
      param out          : El objeto del tipo OB_IAX_BASESTECNICAS con los valores de esos importes
      param out mensajes : mensajes de error
      return             : 0 si todo va bien o  1.
   *************************************************************************/
   FUNCTION f_obtbasestecnicas(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pbastec IN OUT ob_iax_basestecnicas,
      mensajes IN OUT t_iax_mensajes,
      ptabla IN VARCHAR2 DEFAULT 'SEG')
      RETURN NUMBER IS
      i              NUMBER;
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psseguro= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' pnmovimi= ' || pnmovimi
            || 'ptabla= ' || ptabla;
      vobject        VARCHAR2(200) := 'PAC_MD_BASESTECNICAS.f_ObtBasesTecnicas';
      v_sproduc      productos.sproduc%TYPE;
      v_t_tabmortgar t_tabmortgar;
      v_t_inttecgarantias t_inttecgarantias;
      v_t_gastos     t_gastos;
      v_t_intseguro  t_iax_intertecseg;
      vfecha         VARCHAR(20);
      vselect        VARCHAR2(2000);
      vselect2       VARCHAR2(2000);
      vsquery        VARCHAR2(2000);
      vrefcursor     sys_refcursor;
      vsseguro       intertecseg.sseguro%TYPE;
      vfefemov       intertecseg.fefemov%TYPE;
      vnmovimi       intertecseg.nmovimi%TYPE;
      vfmovdia       intertecseg.fmovdia%TYPE;
      vpinttec       intertecseg.pinttec%TYPE;
      vndesde        intertecseg.ndesde%TYPE;
      vnhasta        intertecseg.nhasta%TYPE;
      vninntec       intertecseg.ninntec%TYPE;
      vfvencimcapgar DATE;

      CURSOR c_bastec(par_sproduc NUMBER) IS
         SELECT ctipo, tfuncion
           FROM prodbasestecnicas
          WHERE sproduc = par_sproduc;
   BEGIN
      IF psseguro IS NULL
         --OR pnriesgo IS NULL
         OR pnmovimi IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      IF ptabla = 'EST' THEN
         SELECT sproduc
           INTO v_sproduc
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSE
         SELECT sproduc
           INTO v_sproduc
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      -- Bug 12342 - JRH - 18/01/2010 - 0012342: Mostrar bases técnicas
      IF NVL(f_parproductos_v(v_sproduc, 'VER_BAS_TECN'), 0) = 0 THEN
         pbastec := ob_iax_basestecnicas();
         pbastec := NULL;
         RETURN 0;
      END IF;

      -- fi Bug 12342 - JRH - 18/01/2010
      vpasexec := 3;
      pbastec := ob_iax_basestecnicas();
      pbastec.sseguro := psseguro;
--jrh Cambiar la funcion f_obdatosini a pac_seguros u otro package a nivel de negocio
      vnumerr := f_obtdatosini(psseguro, pnriesgo, pnmovimi, pbastec.fecrevi,
                               pbastec.fecreviant, pbastec.intpol, pbastec.intpolini,
                               pbastec.intpolmin, ptabla);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 4;

      -- Se recupera las bases técnicas de la poliza:
      -- Interes Tecnico a Nivel de Garantia
      -- Tabla Mortalidad
      -- Gastos
      FOR reg IN c_bastec(v_sproduc) LOOP
         --vfecha := TO_CHAR(pfecha, 'dd/mm/yyyy');
         vselect := reg.tfuncion || '(' || psseguro || ',' || pnmovimi || ',''' || ptabla
                    || ''')';
         vselect2 := ' begin :retorno := ' || vselect || ' ; end;';
         vpasexec := 5;

         IF reg.ctipo = 2 THEN   -- Tabla Mortalidad
            -- se ejecuta la funcion de la tabla prodbasesrtecnicas para ctipo = 1
            -- la funcion devuelve un v_t_tabmortgar
            EXECUTE IMMEDIATE vselect2
                        USING OUT v_t_tabmortgar;

            vpasexec := 6;

            IF v_t_tabmortgar IS NOT NULL THEN
               IF v_t_tabmortgar.COUNT > 0 THEN
                  pbastec.tabmortgar := t_iax_tabmortgar();

                  FOR i IN v_t_tabmortgar.FIRST .. v_t_tabmortgar.LAST LOOP
                     IF v_t_tabmortgar.EXISTS(i) THEN
                        pbastec.tabmortgar.EXTEND;
                        pbastec.tabmortgar(i) := ob_iax_tabmortgar();
                        pbastec.tabmortgar(i).cgarant := v_t_tabmortgar(i).cgarant;
                        pbastec.tabmortgar(i).ctabla := v_t_tabmortgar(i).ctabla;
                        pbastec.tabmortgar(i).desctabla := v_t_tabmortgar(i).desctabla;
                     END IF;
                  END LOOP;
               END IF;
            END IF;
         ELSIF reg.ctipo = 1 THEN   -- Interés Técnico a nivel de garantía
            -- se ejecuta la funcion de la tabla prodbasesrtecnicas para ctipo = 2
            -- la funcion devuelve un v_t_inttecgarantias
            EXECUTE IMMEDIATE vselect2
                        USING OUT v_t_inttecgarantias;

            vpasexec := 7;

            IF v_t_inttecgarantias IS NOT NULL THEN
               IF v_t_inttecgarantias.COUNT > 0 THEN
                  pbastec.intgarantias := t_iax_inttecgarantias();

                  FOR i IN v_t_inttecgarantias.FIRST .. v_t_inttecgarantias.LAST LOOP
                     IF v_t_inttecgarantias.EXISTS(i) THEN
                        pbastec.intgarantias.EXTEND;
                        pbastec.intgarantias(i) := ob_iax_inttecgarantias();
                        pbastec.intgarantias(i).nriesgo := v_t_inttecgarantias(i).nriesgo;
                        pbastec.intgarantias(i).cgarant := v_t_inttecgarantias(i).cgarant;
                        pbastec.intgarantias(i).ctipo := v_t_inttecgarantias(i).ctipo;
                        pbastec.intgarantias(i).desctipo := v_t_inttecgarantias(i).desctipo;
                        pbastec.intgarantias(i).fefemov := v_t_inttecgarantias(i).fefemov;
                        pbastec.intgarantias(i).pinttec := v_t_inttecgarantias(i).pinttec;
                        pbastec.intgarantias(i).ndesde := v_t_inttecgarantias(i).ndesde;
                        pbastec.intgarantias(i).nhasta := v_t_inttecgarantias(i).nhasta;
                        pbastec.intgarantias(i).ninttec := v_t_inttecgarantias(i).ninttec;
                     END IF;
                  END LOOP;
               END IF;
            END IF;
         ELSIF reg.ctipo = 3 THEN   -- Gastos
            -- se ejecuta la funcion de la tabla prodbasesrtecnicas para ctipo = 3
            -- la funcion devuelve un v_t_gastos
            EXECUTE IMMEDIATE vselect2
                        USING OUT v_t_gastos;

            vpasexec := 8;

            IF v_t_gastos IS NOT NULL THEN
               IF v_t_gastos.COUNT > 0 THEN
                  pbastec.gastos := t_iax_gastos();

                  FOR i IN v_t_gastos.FIRST .. v_t_gastos.LAST LOOP
                     IF v_t_gastos.EXISTS(i) THEN
                        pbastec.gastos.EXTEND;
                        pbastec.gastos(i) := ob_iax_gastos();
                        pbastec.gastos(i).tipogasto := v_t_gastos(i).tipogasto;
                        pbastec.gastos(i).valor := v_t_gastos(i).valor;
                        pbastec.gastos(i).nivel := v_t_gastos(i).nivel;
                        pbastec.gastos(i).descnivel := v_t_gastos(i).descnivel;
                     END IF;
                  END LOOP;
               END IF;
            END IF;
         -- Bug 12485 - APD - 29/12/2009 - se añade el campo fvencimcapgar en el objeto OB_IAX_BASESTECNICAS
         ELSIF reg.ctipo = 4 THEN   -- Fecha de Vencimiento para capitales garantizado
            -- se ejecuta la funcion de la tabla prodbasesrtecnicas para ctipo = 4
            -- la funcion devuelve un date
            EXECUTE IMMEDIATE vselect2
                        USING OUT vfvencimcapgar;

            vpasexec := 8;
            pbastec.fvencimcapgar := vfvencimcapgar;
         END IF;
      END LOOP;

      vpasexec := 9;

      -- Se recupera los interes tecnicos de la poliza
      IF ptabla = 'EST' THEN
         vsquery :=
            'SELECT sseguro, fefemov, nmovimi, fmovdia, pinttec, ndesde, nhasta, ninntec
                    FROM estintertecseg WHERE sseguro = '
            || psseguro || ' ORDER BY fefemov DESC';
      ELSE
         vsquery :=
            'SELECT sseguro, fefemov, nmovimi, fmovdia, pinttec, ndesde, nhasta, ninntec
                    FROM intertecseg WHERE sseguro = '
            || psseguro || ' ORDER BY fefemov DESC';
      END IF;

      vrefcursor := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      i := 0;
      vpasexec := 10;
      pbastec.intseguro := t_iax_intertecseg();

      LOOP
         FETCH vrefcursor
          INTO vsseguro, vfefemov, vnmovimi, vfmovdia, vpinttec, vndesde, vnhasta, vninntec;

         EXIT WHEN vrefcursor%NOTFOUND;
         i := i + 1;
         pbastec.intseguro.EXTEND;
         pbastec.intseguro(i) := ob_iax_intertecseg();
         pbastec.intseguro(i).sseguro := vsseguro;
         pbastec.intseguro(i).fefemov := vfefemov;
         pbastec.intseguro(i).nmovimi := vnmovimi;
         pbastec.intseguro(i).fmovdia := vfmovdia;
         pbastec.intseguro(i).pinttec := vpinttec;
         pbastec.intseguro(i).ndesde := vndesde;
         pbastec.intseguro(i).nhasta := vnhasta;
         pbastec.intseguro(i).ninttec := vninntec;
      END LOOP;

      vpasexec := 11;

      IF vrefcursor%ISOPEN THEN
         CLOSE vrefcursor;
      END IF;

      vpasexec := 12;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         -- BUG -21546_108724- 07/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_obtbasestecnicas;
END pac_md_basestecnicas;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_BASESTECNICAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_BASESTECNICAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_BASESTECNICAS" TO "PROGRAMADORESCSI";
