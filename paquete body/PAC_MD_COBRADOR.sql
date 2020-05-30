--------------------------------------------------------
--  DDL for Package Body PAC_MD_COBRADOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_COBRADOR" IS
/******************************************************************************
   NOMBRE:       pac_md_cobrador
   PROPÓSITO: Package para el mantenimiento de cobradores bancarios.

   REVISIONES:

   Ver        Fecha        Autor      Descripción
   ---------  ----------  ------      ------------------------------------
     1        29/09/2010   ICV        1. Creación del package
     2        25/01/2010   LCF        2. Añadir parámetros al objeto bancario
     3        08/11/2011   APD        3. 0019986: LCOL_A001-Referencias agrupadas o consecutivas
     4        22/09/2014   CASANCHEZ  4. 0032668: COLM004-Trapaso entre Bancos (cobrador bancario) manteniendo la nómina
******************************************************************************/

   /*****************************************************************************
        Función que selecciona todos los cobradores que cumplan con los parámetros de entrada de la consulta.
        PCEMPRES: Código de la empresa.
        PCCOBBAN: Número de cobrador.
        PCTIPBAN: Código tipo de cuenta
        PCDOMENT: Código de la Entidad
        PTSUFIJO: Sufijo asignado a la norma 19
        PCDOMSUC: Código Sucursal
        PCRAMO: Ramo
        PCMODALI: Modalidad
        PCCOLECT: Colectividad
        PCTIPSEG: Tipo de seguro
        PCAGENTE: Mediador
        PCBANCO: Código Banco
        param in out  : MENSAJES Missatges de sortida.
   *****************************************************************************/
   FUNCTION f_get_cobrador(
      pcempres IN NUMBER,
      pccobban IN NUMBER,
      pctipban IN NUMBER,
      pcdoment IN NUMBER,
      ptsufijo IN VARCHAR2,
      pcdomsuc IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      pcbanco IN NUMBER,
      pncuenta IN VARCHAR2,
      pcobrador OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      squery         VARCHAR(4000);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - PCEMPRES: ' || pcempres || ' - PCEMPRES: ' || pcempres
            || ' - PCCOBBAN: ' || pccobban || ' - PCTIPBAN: ' || pcempres || ' - PCDOMENT: '
            || pcdoment || ' - PTSUFIJO: ' || ptsufijo || ' - PCDOMSUC: ' || pcdomsuc
            || ' - PCRAMO: ' || pcramo || ' - PSPRODUC: ' || psproduc || ' - PCAGENTE: '
            || pcagente || ' - PCBANCO: ' || pcbanco || ' - PNCUENTA: ' || pncuenta;
      vobject        VARCHAR2(200) := 'PAC_MD_COBRADOR.F_GET_COBRADOR';
      vcempres       NUMBER;
      vwhere         VARCHAR2(4000);
      vorden         VARCHAR2(100);
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vccolect       NUMBER;
      vctipseg       NUMBER;
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa;
      ELSE
         vcempres := pcempres;
      END IF;

      vpasexec := 2;
      vwhere := ' and c.cempres = ' || vcempres;

      IF pcramo IS NOT NULL THEN
         vwhere := vwhere || ' and s.cramo = ' || pcramo;
      END IF;

      IF pccobban IS NOT NULL THEN
         vwhere := vwhere || ' and c.ccobban = ' || pccobban;
      END IF;

      IF pcagente IS NOT NULL THEN
         vwhere := vwhere || ' and s.cagente = ' || pcagente;
      END IF;

      IF pctipban IS NOT NULL THEN
         vwhere := vwhere || ' and c.ctipban = ' || pctipban;
      END IF;

      IF pncuenta IS NOT NULL THEN
         vwhere := vwhere || ' and c.ncuenta = ' || CHR(39) || pncuenta || CHR(39);
      END IF;

      IF pcbanco IS NOT NULL THEN
         vwhere := vwhere || ' and s.cbanco = ' || pcbanco;
      END IF;

      IF pcdoment IS NOT NULL THEN
         vwhere := vwhere || ' and c.cdoment = ' || pcdoment;
      END IF;

      IF pcdomsuc IS NOT NULL THEN
         vwhere := vwhere || ' and c.cdomsuc = ' || pcdomsuc;
      END IF;

      IF ptsufijo IS NOT NULL THEN
         vwhere := vwhere || ' and c.tsufijo = ' || CHR(39) || ptsufijo || CHR(39);
      END IF;

      IF psproduc IS NOT NULL THEN
         SELECT cramo, cmodali, ccolect, ctipseg
           INTO vcramo, vcmodali, vccolect, vctipseg
           FROM productos
          WHERE sproduc = psproduc;

         IF pcramo IS NULL THEN
            vwhere := vwhere || ' and s.cramo = ' || vcramo;
         END IF;

         vwhere := vwhere || ' and s.cmodali = ' || vcmodali || ' and s.ccolect = ' || vccolect
                   || ' and s.ctipseg = ' || vctipseg;
      END IF;

      vorden := ' order by c.ccobban desc';
      -- Bug 19986 - APD - 08/11/2011 - se añade el campo cagruprec
      squery :=
         ' SELECT distinct c.ccobban, ncuenta, tsufijo, c.cempres, cdoment, cdomsuc,  nprisel, cbaja, descripcion,
                    nnumnif, tcobban, c.ctipban, ccontaban, dom_filler_ln3, ttipo ||'' - ''||ncuenta descuenta,
                    cagruprec
                    FROM cobbancario c, cobbancariosel s, tipos_cuentades tc
                    WHERE c.cempres = s.cempres(+)
                    AND c.ccobban = s.ccobban(+)
                    and tc.CIDIOMA = '
         || pac_md_common.f_get_cxtidioma || ' and tc.ctipban = c.ctipban ';
      -- Fin Bug 19986 - APD - 08/11/2011
      squery := squery || vwhere || vorden;
      pcobrador := pac_iax_listvalores.f_opencursor(squery, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF pcobrador%ISOPEN THEN
            CLOSE pcobrador;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF pcobrador%ISOPEN THEN
            CLOSE pcobrador;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF pcobrador%ISOPEN THEN
            CLOSE pcobrador;
         END IF;

         RETURN 1;
   END f_get_cobrador;

   /*****************************************************************************
        Función que selecciona todos los cobradores que cumplan con los parámetros de entrada de la consulta.
        PCCOBBAN: Número de cobrador.
        param in out  : MENSAJES Missatges de sortida.
   *****************************************************************************/
   FUNCTION f_get_cobrador_det(
      pccobban IN NUMBER,
      pobjban OUT t_iax_cobbancario,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      squery         VARCHAR(1000);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - PCCOBBAN: ' || pccobban;
      vobject        VARCHAR2(200) := 'PAC_MD_COBRADOR.F_GET_COBRADOR_DET';
      vwhere         VARCHAR2(4000);
      vorden         VARCHAR2(100);
      v_descuenta    VARCHAR2(200);
   BEGIN
      IF pccobban IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pobjban IS NULL THEN
         pobjban := t_iax_cobbancario();
      END IF;

      -- Bug 19986 - APD - 08/11/2011 - se añade el campo cagruprec
      FOR cur IN (SELECT ccobban, ncuenta, tsufijo, cempres, cdoment, cdomsuc, nprisel, cbaja,
                         descripcion, nnumnif, tcobban, ctipban, ccontaban, dom_filler_ln3,
                         precimp, cagruprec
                    FROM cobbancario
                   WHERE ccobban = pccobban) LOOP
         pobjban.EXTEND;
         pobjban(pobjban.LAST) := ob_iax_cobbancario();
         pobjban(pobjban.LAST).ccobban := cur.ccobban;
         pobjban(pobjban.LAST).ncuenta := cur.ncuenta;

         IF cur.ctipban IS NOT NULL THEN
            BEGIN
               SELECT UPPER(ttipo) || ' - ' || cur.ncuenta
                 INTO v_descuenta
                 FROM tipos_cuentades tc
                WHERE cur.ctipban = tc.ctipban
                  AND tc.cidioma = pac_md_common.f_get_cxtidioma;
            EXCEPTION
               WHEN OTHERS THEN
                  v_descuenta := '**';
            END;
         END IF;

         pobjban(pobjban.LAST).ttipban := v_descuenta;
         pobjban(pobjban.LAST).ctipban := cur.ctipban;
         pobjban(pobjban.LAST).cdoment := cur.cdoment;
         pobjban(pobjban.LAST).cdomsuc := cur.cdomsuc;
         pobjban(pobjban.LAST).descripcion := cur.descripcion;
         pobjban(pobjban.LAST).nprisel := cur.nprisel;
         pobjban(pobjban.LAST).tsufijo := cur.tsufijo;
         pobjban(pobjban.LAST).cbaja := cur.cbaja;
         pobjban(pobjban.LAST).nnumnif := cur.nnumnif;
         pobjban(pobjban.LAST).precimp := cur.precimp;
         pobjban(pobjban.LAST).dom_filler_ln3 := cur.dom_filler_ln3;
         pobjban(pobjban.LAST).ccontaban := cur.ccontaban;
         pobjban(pobjban.LAST).tcobban := cur.tcobban;
         -- Bug 19986 - APD - 08/11/2011 - se añade el campo cagruprec
         pobjban(pobjban.LAST).cagruprec := cur.cagruprec;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_cobrador_det;

   /*****************************************************************************
        Función que selecciona la información de la selección del cobrador para uno en concreto.
        PCCOBBAN: Número de cobrador.
        param in out  : MENSAJES Missatges de sortida.
   *****************************************************************************/
   FUNCTION f_get_cobrador_sel(
      pccobban IN NUMBER,
      pnorden IN NUMBER,
      pccobbansel OUT t_iax_cobbancariosel,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000) := 'PCCOBBAN:' || pccobban;
      vobject        VARCHAR2(200) := 'PAC_MD_COMISIONES.f_get_COBRADOR_SEL';
      num_err        NUMBER := 0;
   BEGIN
      IF pccobban IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pccobbansel IS NULL THEN
         pccobbansel := t_iax_cobbancariosel();
      END IF;

      FOR cur IN (SELECT   ccobban, norden, cramo, ctipseg, cempres, ccolect, cbanco, cmodali,
                           cagente, ctipage
                      FROM cobbancariosel
                     WHERE ccobban = pccobban
                       AND(pnorden IS NULL
                           OR pnorden = norden)
                  ORDER BY ccobban, norden DESC) LOOP
         pccobbansel.EXTEND;
         pccobbansel(pccobbansel.LAST) := ob_iax_cobbancariosel();
         pccobbansel(pccobbansel.LAST).ccobban := cur.ccobban;
         pccobbansel(pccobbansel.LAST).norden := cur.norden;
         pccobbansel(pccobbansel.LAST).cramo := cur.cramo;

         IF cur.cramo IS NOT NULL THEN
            BEGIN
               SELECT tramo
                 INTO pccobbansel(pccobbansel.LAST).tramo
                 FROM ramos
                WHERE cidioma = pac_md_common.f_get_cxtidioma
                  AND cramo = cur.cramo;
            EXCEPTION
               WHEN OTHERS THEN
                  pccobbansel(pccobbansel.LAST).tramo := '**';
            END;
         END IF;

         IF cur.cramo IS NOT NULL
            AND cur.cmodali IS NOT NULL
            AND cur.ctipseg IS NOT NULL
            AND cur.ccolect IS NOT NULL THEN
            BEGIN
               SELECT ttitulo
                 INTO pccobbansel(pccobbansel.LAST).ttitulo
                 FROM titulopro
                WHERE cidioma = pac_md_common.f_get_cxtidioma
                  AND cramo = cur.cramo
                  AND ctipseg = cur.ctipseg
                  AND cmodali = cur.cmodali
                  AND ccolect = cur.ccolect;
            EXCEPTION
               WHEN OTHERS THEN
                  pccobbansel(pccobbansel.LAST).ttitulo := '**';
            END;

            BEGIN
               SELECT sproduc
                 INTO pccobbansel(pccobbansel.LAST).sproduc
                 FROM productos
                WHERE cramo = cur.cramo
                  AND ctipseg = cur.ctipseg
                  AND cmodali = cur.cmodali
                  AND ccolect = cur.ccolect;
            EXCEPTION
               WHEN OTHERS THEN
                  pccobbansel(pccobbansel.LAST).sproduc := NULL;
            END;
         END IF;

         pccobbansel(pccobbansel.LAST).ctipseg := cur.ctipseg;
         pccobbansel(pccobbansel.LAST).cempres := cur.cempres;
         pccobbansel(pccobbansel.LAST).ccolect := cur.ccolect;
         pccobbansel(pccobbansel.LAST).cbanco := cur.cbanco;

         IF cur.cbanco IS NOT NULL THEN
            BEGIN
               SELECT tbanco
                 INTO pccobbansel(pccobbansel.LAST).tbanco
                 FROM bancos
                WHERE cbanco = cur.cbanco;
            EXCEPTION
               WHEN OTHERS THEN
                  pccobbansel(pccobbansel.LAST).tbanco := NULL;
            END;
         END IF;

         pccobbansel(pccobbansel.LAST).cmodali := cur.cmodali;
         pccobbansel(pccobbansel.LAST).cagente := cur.cagente;

         IF cur.cagente IS NOT NULL THEN
            num_err := f_desagente(cur.cagente, pccobbansel(pccobbansel.LAST).tagente);
         END IF;

         pccobbansel(pccobbansel.LAST).ctipage := cur.ctipage;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_cobrador_sel;

   /*************************************************************************
       Nueva función que actualiza la información introducida o modificada del cobrador bancario.
       param pcempres    in : Código de la empresa.
       param PCCOBBAN    IN : Número de cobrador.
       param PCTIPBAN    IN : Código tipo de cuenta
       param PCDOMENT    IN : Código de la Entidad
       param PTSUFIJO    IN : Código Sucursal
       param PNCUENTA    IN : Número de cuenta
       param PCBAJA    IN : Código de baja
       param PCESCRIPCION    IN : Descripción
       param PNNUMNIF    IN : nif
       param CCONTABAN:  Código contable para el cobrador bancario
       param DOM_FILLER_LN3:  Filler para las líneas '3' del fichero de domiciliación
       retorno 0-Correcto, 1-Código error.
   *************************************************************************/
   FUNCTION f_set_cobrador(
      pccobban IN NUMBER,
      pncuenta IN VARCHAR2,
      ptsufijo IN VARCHAR2,
      pcempres IN NUMBER,
      pcdoment IN NUMBER,
      pcdomsuc IN NUMBER,
      pnprisel IN NUMBER,
      pcbaja IN NUMBER,
      pdescrip IN VARCHAR2,
      pnnumnif IN VARCHAR2,
      ptcobban IN VARCHAR2,
      pctipban IN NUMBER,
      pccontaban IN NUMBER,
      pdomfill3 IN VARCHAR2,
      pcmodo IN VARCHAR2,
      pprecimp IN NUMBER,
      pcagruprec IN NUMBER,   -- Bug 19986 - APD - 08/11/2011 - se añade el campo cagruprec
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_COBRADOR.f_set_cobrador';
      vparam         VARCHAR2(500)
         := 'parámetros - pccobban: ' || pccobban || ', pncuenta: ' || pncuenta
            || ' ptsufijo : ' || ptsufijo || ' pcempres : ' || pcempres || ' pcdoment : '
            || pcdoment || ' pcdomsuc : ' || pcdomsuc || ' pnprisel : ' || pnprisel
            || ' pnprisel : ' || pnprisel || ' pcbaja : ' || pcbaja || ' pdescrip : '
            || pdescrip || ' pnnumnif : ' || pnnumnif || ' ptcobban : ' || ptcobban
            || ' pctipban : ' || pctipban || ' pccontaban : ' || pccontaban || ' pdomfill3 : '
            || pdomfill3 || ' precimp : ' || pprecimp || ' pcagruprec :' || pcagruprec;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcempres       NUMBER;
   BEGIN
      IF pccobban IS NULL
         OR pncuenta IS NULL
         OR ptsufijo IS NULL
         OR pcdoment IS NULL
         OR pcdomsuc IS NULL
         OR pnprisel IS NULL
         OR pctipban IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa;
      ELSE
         vcempres := pcempres;
      END IF;

      --Validaciones
      -- Bug 19986 - APD - 08/11/2011 - se añade el campo cagruprec
      vnumerr := pac_cobrador.f_valida_cobrador(pccobban, pncuenta, ptsufijo, vcempres,
                                                pcdoment, pcdomsuc, pnprisel, pcbaja, pdescrip,
                                                pnnumnif, ptcobban, pctipban, pccontaban,
                                                pdomfill3, pprecimp, pcmodo, pcagruprec);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      --Insertamos
      -- Bug 19986 - APD - 08/11/2011 - se añade el campo cagruprec
      vnumerr := pac_cobrador.f_set_cobrador(pccobban, pncuenta, ptsufijo, vcempres, pcdoment,
                                             pcdomsuc, pnprisel, pcbaja, pdescrip, pnnumnif,
                                             ptcobban, pctipban, pccontaban, pdomfill3,
                                             pprecimp, pcagruprec);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_cobrador;

   /*************************************************************************
       Nueva función que actualiza la información introducida o modificada del cobrador bancario.
       param PCCOBBAN    IN : Número de cobrador.
       param PNORDEN    in : Orden prioridad de selección
       param pcempres    in : Código de la empresa.
       param PCRAMO    IN : Ramo
       param PCMODALI    IN : Modalidad
       param PCTIPSEG    IN : Tipo de seguro
       param PCCOLECT    IN : Colectividad
       param PCBANCO    IN : Código Banco
       param PCTIPAGE    IN : Tipo mediador
       param PCAGENTE    IN :  Mediador
       retorno 0-Correcto, 1-Código error.
   *************************************************************************/
   FUNCTION f_set_cobrador_sel(
      pccobban IN NUMBER,
      pnorden IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcempres IN NUMBER,
      pcbanco IN NUMBER,
      pcagente IN NUMBER,
      pctipage IN NUMBER,
      pcmodo IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_COBRADOR.f_set_cobrador_sel';
      vparam         VARCHAR2(500)
         := 'parámetros - pccobban: ' || pccobban || ', pNORDEN: ' || pnorden || ' pCRAMO : '
            || pcramo || ' psproduc : ' || psproduc || ' pCEMPRES : ' || pcempres
            || ' pCBANCO : ' || pcbanco || ' pCAGENTE : ' || pcagente || ' pCTIPAGE : '
            || pctipage;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF pccobban IS NULL
         OR pnorden IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Validaciones
      vnumerr := pac_cobrador.f_valida_cobrador_sel(pccobban, pnorden, pcramo, psproduc,
                                                    pcempres, pcbanco, pcagente, pctipage,
                                                    pcmodo);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      --Insert
      vnumerr := pac_cobrador.f_set_cobrador_sel(pccobban, pnorden, pcramo, psproduc, pcempres,
                                                 pcbanco, pcagente, pctipage);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_cobrador_sel;

   FUNCTION f_get_noucobrador(pccobban OUT NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_COBRADOR.f_get_noucobrador';
      vparam         VARCHAR2(500) := 'parámetros -  ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      SELECT NVL(MAX(ccobban), 0) + 1
        INTO pccobban
        FROM cobbancario;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_noucobrador;

   /*************************************************************************
     Nueva función que retorna la descripción de un banco
     retorno 0-Correcto, 1-Código error.
   *************************************************************************/
   FUNCTION f_get_desbanco(pcbanco IN NUMBER, ptbanco OUT VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_COBRADOR.f_get_desbanco';
      vparam         VARCHAR2(500) := 'parámetros -  pcbanco :' || pcbanco;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF pcbanco IS NULL THEN
         RAISE e_param_error;
      END IF;

      BEGIN
         SELECT tbanco
           INTO ptbanco
           FROM bancos
          WHERE cbanco = pcbanco;
      EXCEPTION
         WHEN OTHERS THEN
            ptbanco := NULL;
      END;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_desbanco;

   --
   -- Bug 0032668 Se crea la nueva funcion f_traspaso_cobradores
   --
   /*************************************************************************
     Nueva función que reasliza el traspaso de bancos
     param pcempresa      IN  codigo de la empresa
     param pcobbanorigen  IN  cobrador bancario origen
     param pcbanco        IN  codigo de banco a trapasar
     param pcobbandestino IN  cobrador destino
     param mensajes       OUT mensaje de error
     retorno 0-Correcto, 1-Código error.
    *************************************************************************/
   --
   FUNCTION f_traspaso_cobradores(
      pcempresa IN empresas.cempres%TYPE,
      pcobbanorigen IN cobbancario.ccobban%TYPE,
      pcbanco IN bancos.cbanco%TYPE,
      pcobbandestino IN cobbancario.ccobban%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vobjectname    VARCHAR2(500) := 'PAC_MD_COBRADOR.f_traspaso_cobradores';
      vparam         VARCHAR2(500) := 'parámetros -  pcbanco :' || pcbanco;
      --
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   --
   BEGIN
      --
      vnumerr := pac_cobrador.f_traspaso_cobradores(pcempresa => pcempresa,
                                                    pcobbanorigen => pcobbanorigen,
                                                    pcbanco => pcbanco,
                                                    pcobbandestino => pcobbandestino);
      --
      RETURN vnumerr;
   --
   EXCEPTION
      WHEN e_param_error THEN
         --
         pac_iobj_mensajes.p_tratarmensaje(mensajes => mensajes, pfuncion => vobjectname,
                                           pnerror => 1000005, ptraza => vpasexec,
                                           pparams => vparam);
         --
         RETURN 1;
      --
      WHEN e_object_error THEN
         --
         pac_iobj_mensajes.p_tratarmensaje(mensajes => mensajes, pfuncion => vobjectname,
                                           pnerror => 1000006, ptraza => vpasexec,
                                           pparams => vparam);
         --
         RETURN 1;
      --
      WHEN OTHERS THEN
         --
         pac_iobj_mensajes.p_tratarmensaje(mensajes => mensajes, pfuncion => vobjectname,
                                           pnerror => 1000001, ptraza => vpasexec,
                                           pparams => vparam, psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         --
         RETURN 1;
   --
   END f_traspaso_cobradores;
--
-- Bug 0032668  Fin
--
END pac_md_cobrador;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_COBRADOR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_COBRADOR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_COBRADOR" TO "PROGRAMADORESCSI";
