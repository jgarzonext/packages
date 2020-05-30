--------------------------------------------------------
--  DDL for Package Body PAC_DIRECCIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_DIRECCIONES" AS
   /******************************************************************************
      NOMBRE:    PAC_DIRECCIONES
      PROPOSITO: Funcion que ejecuta dinámicamente la select para obtener la lista de registros
      REVISIONES:
      Ver        Fecha        Autor             Descripcion
      ---------  ----------  ---------------  ------------------------------------
      1.0        19/03/2012   JMB               1. CreaciÃ³n del package.
   ******************************************************************************/

   /*************************************************************************
       Recupera los datos de direcciones de acuerdo a los parametros
      de busqueda dados
       return             : ref cursor
    *************************************************************************/
   FUNCTION f_get_busquedadirdirecciones(
      ptbusqueda IN NUMBER,
      pcpostal IN VARCHAR2,
      pctipvia IN NUMBER,
      pttipvia IN VARCHAR2,
      pndesde IN NUMBER,
      pnhasta IN NUMBER,
      pcdesde IN VARCHAR2,
      pchasta IN VARCHAR2,
      ptipfinca IN NUMBER,
      pcpais IN NUMBER,
      pcprovin IN NUMBER,
      pcmunicipi IN NUMBER,
      pclocalidad IN NUMBER,
      paliasfinca IN VARCHAR2,
      pine IN VARCHAR2,
      pescalera IN NUMBER,
      ppiso IN NUMBER,
      ppuerta IN VARCHAR2,
      preferencia IN VARCHAR2,
      pidfinca IN NUMBER)
      RETURN VARCHAR2 IS
      vtraza         NUMBER;
      vquery         VARCHAR2(2000);
      vquerybody     VARCHAR2(2000);
      vqueryform     VARCHAR2(2000);
      verr           ob_error;
   BEGIN
      vquery :=
         'SELECT distinct(F.IDFINCA),T.CTIPVIA,T.CSIGLAS, C.TCALLE, G.NDESDE, G.TDESDE, G.CPOSTAL, L.IDLOCAL, L.TLOCALI,'
         || ' PO.CPOBLAC, PO.TPOBLAC, PR.CPROVIN, PR.TPROVIN, PA.CPAIS, PA.TPAIS, C.CFUENTE,  '
         || ' F.IDLOCAL, F.CCATAST, F.CTIPFIN, F.NANYCON, F.TFINCA, F.CNOASEG, F.TNOASEG ';
      vqueryform :=
         'FROM DIR_DOMICILIOS D, DIR_GEODIRECCIONES G, DIR_CALLES C, TIPOSVIAS T, DIR_LOCALIDADES L, '
         || '  POBLACIONES PO, PROVINCIAS PR, PAISES PA, DIR_FINCAS F ';
      vquerybody :=
         'WHERE D.IDGEODIR = G.IDGEODIR AND G.IDCALLE = C.IDCALLE AND C.CTIPVIA = T.CTIPVIA AND C.IDLOCAL = L.IDLOCAL '
         || 'AND L.CPROVIN = PO.CPROVIN AND L.CPOBLAC = PO.CPOBLAC AND PO.CPROVIN = PR.CPROVIN '
         || 'AND PR.CPAIS = PA.CPAIS AND D.IDFINCA = F.IDFINCA ';

      IF ptbusqueda IS NOT NULL
         AND ptbusqueda = 1 THEN
         -- CPOSTAL
         IF pcpostal IS NOT NULL THEN
            vquerybody := vquerybody || 'AND G.CPOSTAL = ' || CHR(39) || pcpostal || CHR(39)
                          || ' ';
         END IF;

         -- CTIPVIA
         IF pctipvia IS NOT NULL
            AND pctipvia > 0 THEN
            vquerybody := vquerybody || 'AND C.CTIPVIA = ' || pctipvia || ' ';
         END IF;

         -- TTIPVIA
         IF pttipvia IS NOT NULL THEN
            vquerybody := vquerybody || 'AND upper(C.TCALLE) like ' || CHR(39) || '%'
                          || UPPER(pttipvia) || '%' || CHR(39) || ' ';
         END IF;

         -- CPAIS
         IF pcpais IS NOT NULL
            AND pcpais > 0 THEN
            vquerybody := vquerybody || 'AND PA.CPAIS = ' || pcpais || ' ';
         END IF;

         -- CPROVIN
         IF pcprovin IS NOT NULL
            AND pcprovin > 0 THEN
            vquerybody := vquerybody || 'AND PR.CPROVIN = ' || pcprovin || ' ';
         END IF;

         -- CPLOCALIDAD
         IF pclocalidad IS NOT NULL
            AND pclocalidad > 0 THEN
            vquerybody := vquerybody || 'AND L.IDLOCAL = ' || pclocalidad || ' ';
         END IF;

         -- ACMUNICIPI
         IF pcmunicipi IS NOT NULL
            AND pcmunicipi > 0 THEN
            vquerybody := vquerybody || 'AND PO.CPOBLAC = ' || pcmunicipi || ' ';
         END IF;

         -- AESCALERA
         IF pescalera IS NOT NULL
            AND pescalera > 0 THEN
            vquerybody := vquerybody || 'AND D.CESCALE = ' || pescalera || ' ';
         END IF;

         -- APISO
         IF ppiso IS NOT NULL
            AND ppiso > 0 THEN
            vquerybody := vquerybody || 'AND D.CPLANTA = ' || ppiso || ' ';
         END IF;

         -- APUERTA
         IF ppuerta IS NOT NULL THEN
            vquerybody := vquerybody || 'AND D.CPUERTA = ' || CHR(39) || ppuerta || CHR(39)
                          || ' ';
         END IF;

         -- ALAIASFINCA
         IF paliasfinca IS NOT NULL THEN
            vquerybody := vquerybody || 'AND D.TALIAS like ' || CHR(39) || paliasfinca
                          || CHR(39) || ' ';
         END IF;

         IF pidfinca IS NOT NULL THEN
            vquerybody := vquerybody || 'AND F.IDFINCA = ' || pidfinca || ' ';
         END IF;
      ELSIF ptbusqueda IS NOT NULL
            AND ptbusqueda = 2 THEN
         vquerybody := vquerybody || 'AND D.CCATAST = ' || CHR(39) || preferencia || CHR(39)
                       || ' ';
      END IF;

      vquery := vquery || vqueryform || vquerybody;
      RETURN vquery;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_direcciones.f_get_busquedadirdirecciones',
                     vtraza, 'Error no controlado', SQLERRM);
         RETURN NULL;   -- Error no controlado
   END f_get_busquedadirdirecciones;

   FUNCTION f_get_busquedaportales(pidfinca IN NUMBER, pidportal IN NUMBER)
      RETURN VARCHAR2 IS
      vtraza         NUMBER;
      vquery         VARCHAR2(2000);
      vquerybody     VARCHAR2(2000);
      vqueryform     VARCHAR2(2000);
   BEGIN
      vquery := 'select p.*, t.csiglas, c.tcalle, g.ndesde, g.nhasta, g.tdesde,g.thasta ';
      vqueryform :=
         'from dir_portales p, dir_portalesdirecciones pd, dir_geodirecciones g, '
         || 'dir_calles c, tiposvias t ';
      vquerybody :=
         'where p.idportal = pd.idportal and p.idfinca = pd.idfinca and pd.idgeodir = g.idgeodir'
         || ' and g.idcalle = c.idcalle and c.ctipvia = t.ctipvia ';

      IF pidfinca IS NOT NULL THEN
         vquerybody := vquerybody || ' and p.idfinca = ' || pidfinca || ' ';
      END IF;

      IF pidportal IS NOT NULL THEN
         vquerybody := vquerybody || ' and p.idportal = ' || pidportal || ' ';
      END IF;

      vquery := vquery || vqueryform || vquerybody;
      RETURN vquery;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_direcciones.f_get_busquedaportales', vtraza,
                     'Error no controlado pidfinca' || pidfinca, SQLERRM);
         RETURN NULL;   -- Error no controlado
   END f_get_busquedaportales;

     /*************************************************************************
     Retorna los domicilios de un portal
     param in pidfinca   : Codi de la finca
     param in pidportal  : Codi del portal
     return              : Consulta a ejecutar

     Bug 20893/111636 - 05/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_departamentos(pidfinca IN NUMBER, pidportal IN NUMBER, piddomici IN NUMBER)
      RETURN VARCHAR2 IS
      vtraza         NUMBER;
      vquery         VARCHAR2(2000);
      vquerybody     VARCHAR2(2000);
      vqueryform     VARCHAR2(2000);
   BEGIN
      vquery :=
         'select d.iddomici,d.idfinca,d.idportal,d.idgeodir,d.cescale,d.cplanta,d.cpuerta,d.ctipdpt,'
         || 'd.talias,d.cnoaseg,d.tnoaseg,g.ndesde,c.tcalle,c.ctipvia';
      vqueryform := ' from dir_domicilios d,dir_geodirecciones g,dir_calles c ';

      IF pidfinca IS NOT NULL THEN
         vquerybody := vquerybody || ' where d.idfinca = ' || pidfinca || ' ';
      END IF;

      IF pidportal IS NOT NULL
         AND vquerybody IS NOT NULL THEN
         vquerybody := vquerybody || ' and d.idportal = ' || pidportal || ' ';
      ELSIF pidportal IS NOT NULL THEN
         vquerybody := vquerybody || ' where d.idportal = ' || pidportal || ' ';
      END IF;

      IF piddomici IS NOT NULL
         AND vquerybody IS NOT NULL THEN
         vquerybody := vquerybody || ' and d.iddomici = ' || piddomici || ' ';
      ELSIF piddomici IS NOT NULL THEN
         vquerybody := vquerybody || ' where d.iddomici = ' || piddomici || ' ';
      END IF;

      IF vquerybody IS NOT NULL THEN
         vquerybody := vquerybody || ' and d.idgeodir = g.idgeodir and g.idcalle = c.idcalle ';
      ELSE
         vquerybody := vquerybody
                       || ' where d.idgeodir = g.idgeodir and g.idcalle = c.idcalle ';
      END IF;

      vquery := vquery || vqueryform || vquerybody;
      RETURN vquery;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_direcciones.f_get_departamentos', vtraza,
                     'Error no controlado pidfinca' || pidfinca, SQLERRM);
         RETURN NULL;   -- Error no controlado
   END f_get_departamentos;

     /*************************************************************************
     Retorna una finca
     param in piddomici   : Codi del domicilio
     return              : Consulta a ejecutar

     Bug 20893/111636 - 05/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_finca(pidfinca IN NUMBER)
      RETURN VARCHAR2 IS
      vtraza         NUMBER;
      vquery         VARCHAR2(2000);
   BEGIN
      vquery :=
         'SELECT distinct(F.IDFINCA),T.CTIPVIA,T.CSIGLAS, C.TCALLE, G.NDESDE, G.TDESDE, G.CPOSTAL, L.IDLOCAL, L.TLOCALI,'
         || ' PO.CPOBLAC, PO.TPOBLAC, PR.CPROVIN, PR.TPROVIN, PA.CPAIS, PA.TPAIS, C.CFUENTE,  '
         || ' F.IDLOCAL, F.CCATAST, F.CTIPFIN, F.NANYCON, F.TFINCA, F.CNOASEG, F.TNOASEG, '
         || ' ff_desvalorfijo(800081,' || pac_md_common.f_get_cxtidioma()
         || ',1) TFUENTE, P.CPRINCIP'
         || ' FROM DIR_DOMICILIOS D, DIR_GEODIRECCIONES G, DIR_CALLES C, TIPOSVIAS T, DIR_LOCALIDADES L, '
         || '  POBLACIONES PO, PROVINCIAS PR, PAISES PA, DIR_FINCAS F, DIR_PORTALES  P '
         || ' WHERE D.IDGEODIR = G.IDGEODIR AND G.IDCALLE = C.IDCALLE AND C.CTIPVIA = T.CTIPVIA AND C.IDLOCAL = L.IDLOCAL '
         || ' AND L.CPROVIN = PO.CPROVIN AND L.CPOBLAC = PO.CPOBLAC AND PO.CPROVIN = PR.CPROVIN '
         || ' AND PR.CPAIS = PA.CPAIS AND D.IDFINCA = F.IDFINCA ' || ' AND F.IDFINCA = '
         || pidfinca || ' AND P.IDFINCA = F.IDFINCA AND p.idportal = d.idportal'
         || ' order by P.CPRINCIP desc ';
      RETURN vquery;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_direcciones.f_get_busquedadirdirecciones',
                     vtraza, 'Error no controlado', SQLERRM);
         RETURN NULL;   -- Error no controlado
   END f_get_finca;

    /*************************************************************************
     Guarda un domicilio
     param in pidfinca
     param in pidportal
     param in pidgeodir
     param in pcescale
     param in pcplanta
     param in pcpuerta
     param in pccatast
     param in pnm2cons
     param in pctipdpt
     param in ptalias
     param in pcnoaseg
     param in ptnoaseg
     return  0 - Ok,1 - KO

     Bug 20893/111636 - 16/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_set_domici(
      piddomici IN NUMBER,
      pidfinca IN NUMBER,
      pidportal IN NUMBER,
      pidgeodir IN NUMBER,
      pcescale IN VARCHAR2,
      pcplanta IN VARCHAR2,
      pcpuerta IN VARCHAR2,
      pccatast IN VARCHAR2,
      pnm2cons IN NUMBER,
      pctipdpt IN NUMBER,
      ptalias IN VARCHAR2,
      pcnoaseg IN NUMBER,
      ptnoaseg IN NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER;
      viddomici      NUMBER;
   BEGIN
      vtraza := 1;
      -- if piddomici is null then
      --    select SEQDIR_DOMICILIOS.nextval into viddomici from dual;
       --end if;
      vtraza := 2;

      BEGIN
         INSERT INTO dir_domicilios
                     (iddomici, idfinca, idportal, idgeodir, cescale,
                      cplanta, cpuerta, ccatast, nm2cons, ctipdpt, talias, cnoaseg,
                      tnoaseg)
              VALUES (NVL(piddomici, viddomici), pidfinca, pidportal, pidgeodir, pcescale,
                      pcplanta, pcpuerta, pccatast, pnm2cons, pctipdpt, ptalias, pcnoaseg,
                      ptnoaseg);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            NULL;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_direcciones.f_set_domici', vtraza,
                     'Error no controlado', SQLERRM);
         RETURN SQLERRM;   -- Error no controlado
   END f_set_domici;

    /*************************************************************************
     Guarda una finca
     param in pidfinca
     param in pidlocal
     param in pccatast
     param in pctipfin
     param in pnanycon
     param in ptfinca
     param in pcnoaseg
     param in ptnoaseg
     return  0 - Ok, Codi error - KO

     Bug 20893/111636 - 17/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_set_finca(
      pidfinca IN NUMBER,
      pidlocal IN NUMBER,
      pccatast IN VARCHAR2,
      pctipfin IN NUMBER,
      pnanycon IN NUMBER,
      ptfinca IN VARCHAR2,
      pcnoaseg IN NUMBER,
      ptnoaseg IN NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER;
      vidfinca       NUMBER;
   BEGIN
      vtraza := 1;

      IF pidfinca IS NULL THEN
         SELECT seqdir_fincas.NEXTVAL
           INTO vidfinca
           FROM DUAL;
      END IF;

      vtraza := 2;

      BEGIN
         INSERT INTO dir_fincas
                     (idfinca, idlocal, ccatast, ctipfin, nanycon,
                      tfinca, cnoaseg, tnoaseg)
              VALUES (NVL(pidfinca, vidfinca), pidlocal, pccatast, pctipfin, pnanycon,
                      ptfinca, pcnoaseg, ptnoaseg);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            NULL;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_direcciones.f_set_finca', vtraza,
                     'Error no controlado', SQLERRM);
         RETURN SQLERRM;   -- Error no controlado
   END f_set_finca;

    /*************************************************************************
     Guarda un portal
     param in pidfinca
     param in pidportal
     param in pcprincip
     param in pcnoaseg
     param in ptnoaseg
     param in pnanycon
     param in pndepart
     param in pnplsota
     param in pnplalto
     param in pnascens
     param in pnescale
     param in pnm2vivi
     param in pnm2come
     param in pnm2gara
     param in pnm2jard
     param in pnm2cons
     param in pnm2suel
     return  0 - Ok, Codi error - KO

     Bug 20893/111636 - 17/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_set_portal(
      pidfinca IN NUMBER,
      pidportal IN NUMBER,
      pcprincip IN NUMBER,
      pcnoaseg IN NUMBER,
      ptnoaseg IN NUMBER,
      pnanycon IN NUMBER,
      pndepart IN NUMBER,
      pnplsota IN NUMBER,
      pnplalto IN NUMBER,
      pnascens IN NUMBER,
      pnescale IN NUMBER,
      pnm2vivi IN NUMBER,
      pnm2come IN NUMBER,
      pnm2gara IN NUMBER,
      pnm2jard IN NUMBER,
      pnm2cons IN NUMBER,
      pnm2suel IN NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER;
      vidportal      NUMBER;
   BEGIN
      vtraza := 1;

      IF pidfinca IS NULL THEN
         RETURN 103135;   --Faltan parଥtros
      END IF;

      vtraza := 2;

      IF pidportal IS NULL THEN
         SELECT NVL(MAX(idportal), 1)
           INTO vidportal
           FROM dir_portales
          WHERE idfinca = pidfinca;
      END IF;

      vtraza := 3;

      BEGIN
         INSERT INTO dir_portales
                     (idfinca, idportal, cprincip, cnoaseg, tnoaseg,
                      nanycon, ndepart, nplsota, nplalto, nascens, nescale, nm2vivi,
                      nm2come, nm2gara, nm2jard, nm2cons, nm2suel)
              VALUES (pidfinca, NVL(pidportal, vidportal), pcprincip, pcnoaseg, ptnoaseg,
                      pnanycon, pndepart, pnplsota, pnplalto, pnascens, pnescale, pnm2vivi,
                      pnm2come, pnm2gara, pnm2jard, pnm2cons, pnm2suel);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            NULL;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_direcciones.f_set_portal', vtraza,
                     'Error no controlado', SQLERRM);
         RETURN SQLERRM;   -- Error no controlado
   END f_set_portal;

    /*************************************************************************
     Guarda en portaldirecciones
     param in pidfinca
     param in pidportal
     param in pidgeodir
     param in pcprincip
     return  0 - Ok, Codi error - KO

     Bug 20893/111636 - 17/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_set_portalesdirecciones(
      pidfinca IN NUMBER,
      pidportal IN NUMBER,
      pidgeodir IN NUMBER,
      pcprincip IN NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER;
   BEGIN
      vtraza := 1;

      IF pidfinca IS NULL
         OR pidportal IS NULL
         OR pidgeodir IS NULL THEN
         RETURN 103135;   --Faltan parଥtros
      END IF;

      vtraza := 2;

      BEGIN
         INSERT INTO dir_portalesdirecciones
                     (idfinca, idportal, idgeodir, cprincip)
              VALUES (pidfinca, pidportal, pidgeodir, pcprincip);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            NULL;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_direcciones.f_set_portalesdirecciones', vtraza,
                     'Error no controlado', SQLERRM);
         RETURN SQLERRM;   -- Error no controlado
   END f_set_portalesdirecciones;

   /*************************************************************************
    Retorna si existe un domicilio
    param in pidfinca   : Codi de finca
    param in pidportal  : Codi del portal
    param in piddomici  : Codi del domicilio
    param in pidgeodir  : Codi geodireccion
    param in pcescale   : Codi escalera
    param in pcplanta   : Codi de planta
    param in pcpuerta   : Codi puerta
    param in mensajes   : Mensajes de error
    return              :  0 - No existe , 1 - Existe

    Bug 20893/111636 - 16/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_existe_domi(
      pidfinca IN NUMBER,
      pidportal IN NUMBER,
      piddomici IN NUMBER,
      pidgeodir IN NUMBER,
      pcescale IN VARCHAR2,
      pcplanta IN VARCHAR2,
      pcpuerta IN VARCHAR2,
      vexiste IN OUT NUMBER,
      viddomici IN OUT NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER;
      vparam         VARCHAR2(100)
         := 'pidfinca:' || pidfinca || ' pidportal:' || pidportal || ' piddomici:'
            || piddomici;
      vobject        VARCHAR2(200) := 'PAC_DIRECCIONES.f_existe_domi';
      vcount         NUMBER;
      terror         VARCHAR2(200) := 'Error no controlado';
   BEGIN
      vpasexec := 1;
      vexiste := 0;

      IF pidfinca IS NOT NULL
         AND piddomici IS NOT NULL
         AND pidportal IS NOT NULL THEN
         SELECT COUNT(1)
           INTO vcount
           FROM dir_domicilios
          WHERE iddomici = piddomici
            AND idfinca = pidfinca
            AND idportal = pidportal;

         IF vcount >= 1 THEN
            vexiste := 1;
         END IF;
      --RETURN 0;
      END IF;

      vpasexec := 2;

      IF pidfinca IS NOT NULL
         AND pidportal IS NOT NULL
         AND piddomici IS NULL THEN
         SELECT COUNT(1)
           INTO vcount
           FROM dir_domicilios
          WHERE idfinca = pidfinca
            AND idportal = pidportal;

         IF vcount >= 1 THEN
            vexiste := 1;
         END IF;
      --RETURN 0;
      END IF;

      vpasexec := 3;

      IF pidfinca IS NOT NULL
         AND piddomici IS NULL
         AND pidportal IS NULL THEN
         SELECT COUNT(1)
           INTO vcount
           FROM dir_domicilios
          WHERE idfinca = pidfinca;

         IF vcount >= 1 THEN
            vexiste := 1;
         END IF;
      --RETURN 0;
      END IF;

      IF vexiste = 1 THEN
         SELECT iddomici
           INTO viddomici
           FROM dir_domicilios
          WHERE (iddomici = piddomici
                 OR piddomici IS NULL)
            AND idfinca = pidfinca
            AND idportal = pidportal
            AND(idgeodir = pidgeodir
                OR pidgeodir IS NULL)
            AND NVL(cescale, '*') = NVL(pcescale, '*')
            AND NVL(cplanta, '*') = NVL(pcplanta, '*')
            AND NVL(cpuerta, '*') = NVL(pcpuerta, '*');
      ELSE
         viddomici := NULL;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_direcciones.f_existe_domi', vpasexec,
                     'Error no controlado', SQLERRM);
         RETURN SQLERRM;   -- Error no controlado
   END f_existe_domi;

    /*************************************************************************
    Retorna si existe un domicilio
    param in pidlocal  : Codi de localidad
    param out ptlocali  : Descripcion de la localidad
    return              :  0 - OK,  Codi error - KO

    Bug 20893/111636 - 20/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_localidad(pidlocal IN NUMBER, ptlocali OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER;
      vparam         VARCHAR2(100) := 'pidlocal:' || pidlocal;
      vobject        VARCHAR2(200) := 'PAC_DIRECCIONES.f_get_localidad';
      vcount         NUMBER;
      terror         VARCHAR2(200) := 'Error no controlado';
   BEGIN
      vpasexec := 1;

      IF pidlocal IS NULL THEN
         RETURN 103135;   --Faltan parଥtros
      END IF;

      BEGIN
         SELECT tlocali
           INTO ptlocali
           FROM dir_localidades
          WHERE idlocal = pidlocal;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            ptlocali := NULL;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_direcciones.f_existe_domi', vpasexec,
                     'Error no controlado', SQLERRM);
         RETURN SQLERRM;   -- Error no controlado
   END f_get_localidad;

    /*************************************************************************
    Retorna las siglas de una calle
    param in pctipiva  : Codi de tipo de via
    param out pcsiglas : Siglas
    return              :  0 - OK,  Codi error - KO

    Bug 20893/111636 - 23/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_siglas(pctipiva IN NUMBER, pcsiglas OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER;
      vparam         VARCHAR2(100) := 'pctipiva:' || pctipiva;
      vobject        VARCHAR2(200) := 'PAC_DIRECCIONES.f_get_siglas';
      terror         VARCHAR2(200) := 'Error no controlado';
   BEGIN
      vpasexec := 1;

      IF pctipiva IS NULL THEN
         RETURN 103135;   --Faltan parଥtros
      END IF;

      BEGIN
         SELECT csiglas
           INTO pcsiglas
           FROM tiposvias
          WHERE ctipvia = pctipiva;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pcsiglas := NULL;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_direcciones.f_get_siglas', vpasexec,
                     'Error no controlado', SQLERRM);
         RETURN SQLERRM;   -- Error no controlado
   END f_get_siglas;

    /*************************************************************************
     Guarda en geodirecciones
     param in pidgeodir
     param in pidcalle
     param in pctipnum
     param in pndesde
     param in ptdesde
     param in pnhasta
     param in pthasta
     param in pcpostal
     param in pcgeox
     param in pcgeoy
     param in pcgeonum
     param in pcgeoid
     param in pcvaldir
     return  0 - Ok, Codi error - KO

     Bug 20893/111636 - 24/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_set_dirgeodirecciones(
      pidgeodir IN NUMBER,
      pidcalle IN NUMBER,
      pctipnum IN NUMBER,
      pndesde IN NUMBER,
      ptdesde IN VARCHAR2,
      pnhasta IN NUMBER,
      pthasta IN VARCHAR2,
      pcpostal IN VARCHAR2,
      pcgeox IN VARCHAR2,
      pcgeoy IN VARCHAR2,
      pcgeonum IN NUMBER,
      pcgeoid IN VARCHAR2,
      pcvaldir IN NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER;
   BEGIN
      vtraza := 1;

      IF pidgeodir IS NULL
         OR pcvaldir IS NULL THEN
         RETURN 103135;   --Faltan parଥtros
      END IF;

      vtraza := 2;

      BEGIN
         INSERT INTO dir_geodirecciones
                     (idgeodir, idcalle, ctipnum, ndesde, tdesde, nhasta, thasta,
                      cpostal, cgeox, cgeoy, cgeonum, cgeoid, cvaldir)
              VALUES (pidgeodir, pidcalle, pctipnum, pndesde, ptdesde, pnhasta, pthasta,
                      pcpostal, pcgeox, pcgeoy, pcgeonum, pcgeoid, pcvaldir);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            NULL;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_direcciones.f_set_dirgeodirecciones', vtraza,
                     'Error no controlado', SQLERRM);
         RETURN SQLERRM;   -- Error no controlado
   END f_set_dirgeodirecciones;

    /*************************************************************************
     Guarda en dir_calles
     param in pidcalle
     param in pidlocal
     param in ptcalle
     param in pctipvia
     param in pcfuente
     param in ptcalbus
     param in pcvalcal
     return  0 - Ok, Codi error - KO

     Bug 20893/111636 - 24/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_set_dircalles(
      pidcalle IN NUMBER,
      pidlocal IN NUMBER,
      ptcalle IN VARCHAR2,
      pctipvia IN NUMBER,
      pcfuente IN NUMBER,
      ptcalbus IN VARCHAR2,
      pcvalcal IN NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER;
   BEGIN
      vtraza := 1;

      IF pidcalle IS NULL
         OR pcvalcal IS NULL THEN
         RETURN 103135;   --Faltan parଥtros
      END IF;

      vtraza := 2;

      BEGIN
         INSERT INTO dir_calles
                     (idcalle, idlocal, tcalle, ctipvia, cfuente, tcalbus, cvalcal)
              VALUES (pidcalle, pidlocal, ptcalle, pctipvia, pcfuente, ptcalbus, pcvalcal);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            NULL;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_direcciones.f_set_dircalles', vtraza,
                     'Error no controlado', SQLERRM);
         RETURN SQLERRM;   -- Error no controlado
   END f_set_dircalles;

    /*************************************************************************
     Retorna las localidades
     param in pcprovin   : Codi de la provincia
     param in pcpoblac  : Codi de la poblaci򬋊     return              : Consulta a ejecutar

     Bug 20893/111636 - 26/04/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_localidades(pcprovin IN NUMBER, pcpoblac IN NUMBER)
      RETURN VARCHAR2 IS
      vtraza         NUMBER;
      vquery         VARCHAR2(2000);
      vquerybody     VARCHAR2(2000);
      vqueryform     VARCHAR2(2000);
   BEGIN
      vquery := 'select idlocal,tlocali';
      vqueryform := ' from dir_localidades ';

      IF pcprovin IS NOT NULL THEN
         vquerybody := vquerybody || ' where cprovin = ' || pcprovin || ' ';
      END IF;

      IF pcpoblac IS NOT NULL
         AND vquerybody IS NOT NULL THEN
         vquerybody := vquerybody || ' and cpoblac = ' || pcpoblac || ' ';
      ELSIF pcpoblac IS NOT NULL THEN
         vquerybody := vquerybody || ' where cpoblac = ' || pcpoblac || ' ';
      END IF;

      vquery := vquery || vqueryform || vquerybody;
      RETURN vquery;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_direcciones.f_get_localidades', vtraza,
                     'Error no controlado pcprovin' || pcprovin || ' pcpoblac:' || pcpoblac,
                     SQLERRM);
         RETURN NULL;   -- Error no controlado
   END f_get_localidades;

    /*************************************************************************
     Retorna un portal
     return              : Consulta a ejecutar

     Bug 20893/111636 - 17/05/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_busquedaportal(
      ptbusqueda IN NUMBER,
      pcpostal IN VARCHAR2,
      pctipvia IN NUMBER,
      pttipvia IN VARCHAR2,
      pndesde IN NUMBER,
      pnhasta IN NUMBER,
      pcdesde IN VARCHAR2,
      pchasta IN VARCHAR2,
      ptipfinca IN NUMBER,
      pcpais IN NUMBER,
      pcprovin IN NUMBER,
      pcmunicipi IN NUMBER,
      pclocalidad IN NUMBER,
      paliasfinca IN VARCHAR2,
      pine IN VARCHAR2,
      pescalera IN NUMBER,
      ppiso IN NUMBER,
      ppuerta IN VARCHAR2,
      preferencia IN VARCHAR2)
      RETURN VARCHAR2 IS
      vtraza         NUMBER;
      vquery         VARCHAR2(2000);
      vquerybody     VARCHAR2(2000);
      vqueryform     VARCHAR2(2000);
      verr           ob_error;
   BEGIN
      vquery := 'SELECT DISTINCT g.IDGEODIR, p.*, t.csiglas, c.tcalle, g.ndesde, g.nhasta,'
                || ' g.tdesde,g.thasta ';
      vqueryform :=
         ' FROM dir_domicilios d, dir_geodirecciones g, dir_calles c, tiposvias t, dir_localidades l,'
         || ' poblaciones po, provincias pr, paises pa, dir_portales p,dir_portalesdirecciones pd';
      vquerybody :=
         ' WHERE D.IDGEODIR = G.IDGEODIR AND G.IDCALLE = C.IDCALLE AND C.CTIPVIA = T.CTIPVIA AND C.IDLOCAL = L.IDLOCAL '
         || ' AND L.CPROVIN = PO.CPROVIN AND L.CPOBLAC = PO.CPOBLAC AND PO.CPROVIN = PR.CPROVIN '
         || ' AND PR.CPAIS = PA.CPAIS ';

--        SELECT DISTINCT g.IDGEODIR, p.*, t.ctipvia, t.csiglas, c.tcalle, g.ndesde, g.nhasta,
--                        g.tdesde,g.thasta, g.cpostal
--           FROM dir_domicilios d, dir_geodirecciones g, dir_calles c, tiposvias t,
--                dir_localidades l, poblaciones po, provincias pr, paises pa, dir_portales p,dir_portalesdirecciones pd
--          WHERE d.idgeodir = g.idgeodir
--            AND g.idcalle = c.idcalle
--            AND c.ctipvia = t.ctipvia
--            AND c.idlocal = l.idlocal
--            AND l.cprovin = po.cprovin
--            AND l.cpoblac = po.cpoblac
--            AND po.cprovin = pr.cprovin
--            AND pr.cpais = pa.cpais
--            AND g.cpostal = '08302'
--            AND UPPER(c.tcalle) LIKE '%BRUC%'
--            AND pa.cpais = 42
--            AND pr.cprovin = 8
--            AND l.idlocal = 5
--            AND po.cpoblac = 229
--            and p.IDPORTAL = pd.IDPORTAL
--            and pd.IDGEODIR = g.IDGEODIR
--            and pd.IDFINCA = p.IDFINCA
      IF ptbusqueda IS NOT NULL
         AND ptbusqueda = 1 THEN
         -- CPOSTAL
         IF pcpostal IS NOT NULL THEN
            vquerybody := vquerybody || 'AND G.CPOSTAL = ' || CHR(39) || pcpostal || CHR(39)
                          || ' ';
         END IF;

         -- CTIPVIA
         IF pctipvia IS NOT NULL
            AND pctipvia > 0 THEN
            vquerybody := vquerybody || 'AND C.CTIPVIA = ' || pctipvia || ' ';
         END IF;

         -- TTIPVIA
         IF pttipvia IS NOT NULL THEN
            vquerybody := vquerybody || 'AND upper(C.TCALLE) like ' || CHR(39) || '%'
                          || UPPER(pttipvia) || '%' || CHR(39) || ' ';
         END IF;

         -- CPAIS
         IF pcpais IS NOT NULL
            AND pcpais > 0 THEN
            vquerybody := vquerybody || 'AND PA.CPAIS = ' || pcpais || ' ';
         END IF;

         -- CPROVIN
         IF pcprovin IS NOT NULL
            AND pcprovin > 0 THEN
            vquerybody := vquerybody || 'AND PR.CPROVIN = ' || pcprovin || ' ';
         END IF;

         -- CPLOCALIDAD
         IF pclocalidad IS NOT NULL
            AND pclocalidad > 0 THEN
            vquerybody := vquerybody || 'AND L.IDLOCAL = ' || pclocalidad || ' ';
         END IF;

         -- ACMUNICIPI
         IF pcmunicipi IS NOT NULL
            AND pcmunicipi > 0 THEN
            vquerybody := vquerybody || 'AND PO.CPOBLAC = ' || pcmunicipi || ' ';
         END IF;

         -- AESCALERA
         IF pescalera IS NOT NULL
            AND pescalera > 0 THEN
            vquerybody := vquerybody || 'AND D.CESCALE = ' || pescalera || ' ';
         END IF;

         -- APISO
         IF ppiso IS NOT NULL
            AND ppiso > 0 THEN
            vquerybody := vquerybody || 'AND D.CPLANTA = ' || ppiso || ' ';
         END IF;

         -- APUERTA
         IF ppuerta IS NOT NULL THEN
            vquerybody := vquerybody || 'AND D.CPUERTA = ' || CHR(39) || ppuerta || CHR(39)
                          || ' ';
         END IF;

         -- ALAIASFINCA
         IF paliasfinca IS NOT NULL THEN
            vquerybody := vquerybody || 'AND D.TALIAS like ' || CHR(39) || paliasfinca
                          || CHR(39) || ' ';
         END IF;
      ELSIF ptbusqueda IS NOT NULL
            AND ptbusqueda = 2 THEN
         vquerybody := vquerybody || 'AND D.CCATAST = ' || CHR(39) || preferencia || CHR(39)
                       || ' ';
      END IF;

      vquery := vquery || vqueryform || vquerybody || ' order by p.cprincip desc ';
      RETURN vquery;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_direcciones.f_get_busquedadirdirecciones',
                     vtraza, 'Error no controlado', SQLERRM);
         RETURN NULL;   -- Error no controlado
   END f_get_busquedaportal;
END pac_direcciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_DIRECCIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_DIRECCIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_DIRECCIONES" TO "PROGRAMADORESCSI";
