create or replace PACKAGE BODY "PAC_MD_CONTRAGARANTIAS" IS
   /******************************************************************************
      NOMBRE:    pac_md_contragarantias
      PROPSITO: Funciones para contragarantias

      REVISIONES:
      Ver        Fecha        Autor             Descripcin
      ---------  ----------  ---------------  ------------------------------------
      1.0        02/03/2016  JAE              1. Creacinn del objeto.
      2.0        25/02/2019  ACL              2. TCS_826: Se agrega parmetros a la funcin f_grabar_contragarantia y al llamado de la funcin f_ins_contragaran_det.
	  3.0        28/02/2019  ACL              3. TCS_823: Se agrega validaciones para el tenedor, tipo, clase, estado moneda en la funcin f_grabar_contragarantia.
      4.0        04/03/2019  ACL              4. TCS_823: Se ajusta parmetro SPERFIDE en la funcin f_grabar_contragarantia.
      5.0        05/03/2019  CJMR             5. Se agrega funcin para validacin de marcas
	  6.0        07/03/2019  ACL              6. TCS_823: Se modifica una condicin de validacin en la funcin f_grabar_contragarantia.
	  7.0        11/03/2019  ACL              7. TCS_823: Se agrega validacin estado finalizado y modificacion para el campo auxiliar en la funcin f_grabar_contragarantia.
	  8.0        14/03/2019  ACL              8. TCS_309: Se agrega parametros a la funcion f_grabar_contragarantia
	  9.0        18/03/2019  ACL              9. TCS_309: Se agrega parametros de texto a la funcion f_grabar_contragarantia
   *******************************************************************************/
   --Tipo Contragaranta              AAAAA   8001035
   --Clase Contragaranta             BBBBB   8001036
   --Tenedor                          CCCCC   8001037
   --Estado Contragaranta            DDDDD   8001038
   --Origen Contragaranta            EEEEE   8001039
   --Marca vehculo                   GGGGG   8001040
   --Tipo Servicio vehculo           HHHHH   8001041
   --Color vehculo                   IIIII   8001042
   --Tipo documento Contragaranta    JJJJJ   8001043

   /*************************************************************************
      FUNCTION f_ins_contragaran_pol

      param in pscontgar : Identificador contragaranta
      param in psseguro  : Identificador seguro
      param in pnmovimi  : Nmero de movimiento
      param in ptablas   : Tablas Reales/Estudio
      param in mensajes  : t_iax_mensajes
      return             : NUMBER
   *************************************************************************/
   FUNCTION f_ins_contragaran_pol(pscontgar IN NUMBER,
                                  psseguro  IN NUMBER,
                                  pnmovimi  IN NUMBER,
                                  ptablas   IN VARCHAR2,
                                  mensajes  IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_MD_CONTRAGARANTIAS.f_ins_contragaran_pol';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar || ' psseguro: ' ||
                                psseguro || ' pnmovimi: ' || pnmovimi ||
                                ' ptablas: ' || ptablas;
      --
      vnum_err NUMBER;
      vcsituac NUMBER;
      vcestado NUMBER;
      vcreteni NUMBER;
      vpolizas NUMBER;
      vtomador NUMBER;
	  cont number;
      --
   BEGIN
      --
      IF pscontgar IS NULL OR
         psseguro IS NULL OR
         pnmovimi IS NULL
      THEN
         --
         RAISE e_param_error;
         --
      END IF;
      --
      IF ptablas = 'POL'
      THEN
         --
         SELECT s.csituac,
                s.creteni
           INTO vcsituac,
                vcreteni
           FROM seguros s
          WHERE s.sseguro = psseguro;
         --
         SELECT COUNT(*)
           INTO vtomador
           FROM tomadores
          WHERE sseguro = psseguro
            AND sperson = (SELECT sperson
                             FROM per_contragarantia
                            WHERE scontgar = pscontgar);
         --
         IF vtomador < 1
         THEN
            --
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9909781); --Tomador diferente a la contragaranta
            RAISE e_param_error;
            --
         END IF;
         --
      ELSE
         --
         vcsituac := 0;
         vcreteni := 0;
         --
      END IF;
      --
      vpasexec := 3;
      --
      SELECT c.cestado
        INTO vcestado
        FROM ctgar_contragarantia c
       WHERE c.scontgar = pscontgar
         AND c.nmovimi = (SELECT MAX(nmovimi)
                            FROM ctgar_contragarantia
                           WHERE scontgar = c.scontgar);

	  --
       SELECT COUNT(*)
        into CONT
        FROM CTGAR_CONTRAGARANTIA a,
             CTGAR_SEGURO b
       WHERE a.scontgar=b.scontgar
        AND A.scontgar  =pscontgar
        AND A.CESTADO   =2;

         IF CONT >= 1
         THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 89905769); --No se puede asociar mas de una pliza a una contragarantia cerrada
         RAISE e_param_error;
         END IF;


      --
      SELECT COUNT(*)
        INTO vpolizas
        FROM ctgar_seguro
       WHERE scontgar = pscontgar;
      --
      IF vcsituac != 0 AND
         vcreteni != 0
      THEN
         --
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9908847); --Solo se puede asociar plizas vigentes
         RAISE e_param_error;
         --
      ELSIF vcestado = 2 AND
            vpolizas > 1
      THEN
         --
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                              1,
                                              9908848,
                                              vpolizas); --CONTRAGARANTIAS cerrada vinculada a la pliza
         RAISE e_param_error;
         --
      END IF;
      --
      vnum_err := pac_contragarantias.f_ins_contragaran_pol(pscontgar => pscontgar,
                                                            psseguro  => psseguro,
                                                            pnmovimi  => pnmovimi,
                                                            ptablas   => ptablas,
                                                            mensajes  => mensajes);
      --
      RETURN vnum_err;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_ins_contragaran_pol;

   /*************************************************************************
      FUNCTION f_del_contragaran_pol

      param in pscontgar : Identificador contragaranta
      param in psseguro  : Identificador seguro
      param in pnmovimi  : Nmero de movimiento
      param in mensajes  : t_iax_mensajes
      return             : NUMBER
   *************************************************************************/
   FUNCTION f_del_contragaran_pol(pscontgar IN NUMBER,
                                  psseguro  IN NUMBER,
                                  pnmovimi  IN NUMBER,
                                  mensajes  IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vnum_err NUMBER;
      vobject  VARCHAR2(200) := 'PAC_MD_CONTRAGARANTIAS.f_del_contragaran_pol';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar || ' psseguro: ' ||
                                psseguro || ' pnmovimi: ' || pnmovimi;
      --
   BEGIN
      --
      vnum_err := pac_contragarantias.f_del_contragaran_pol(pscontgar => pscontgar,
                                                            psseguro  => psseguro,
                                                            pnmovimi  => pnmovimi,
                                                            mensajes  => mensajes);
      --
      RETURN vnum_err;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_del_contragaran_pol;

   /*************************************************************************
      FUNCTION f_ins_contragaran_codeu

      param in pscontgar : Identificador contragaranta
      param in psperson  : Identificador psperson
      param in pnmovimi  : Nmero de movimiento
      param in mensajes  : t_iax_mensajes
      return             : NUMBER
   *************************************************************************/
   FUNCTION f_del_contragaran_codeu(pscontgar IN NUMBER,
                                    psperson  IN NUMBER,
                                    pnmovimi  IN NUMBER,
                                    mensajes  IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_MD_CONTRAGARANTIAS.f_del_contragaran_codeu';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar || ' psperson: ' ||
                                psperson || ' pnmovimi: ' || pnmovimi;
      --
      vnum_err  NUMBER;
      vcimpreso NUMBER;
      vctenedor NUMBER;
      --
   BEGIN
      --
      IF pscontgar IS NULL OR
         psperson IS NULL OR
         pnmovimi IS NULL
      THEN
         --
         RAISE e_param_error;
         --
      END IF;
      --
      SELECT c.cimpreso,
             c.ctenedor
        INTO vcimpreso,
             vctenedor
        FROM ctgar_contragarantia c
       WHERE c.scontgar = pscontgar
         AND c.nmovimi = (SELECT MAX(nmovimi)
                            FROM ctgar_contragarantia
                           WHERE scontgar = c.scontgar);
      --
      IF NVL(vcimpreso, 0) = 1 OR
         vctenedor != 1
      THEN
         --
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9908864); --El documento ya ha sido impreso
         RAISE e_param_error;
         --
      END IF;
      --
      vnum_err := pac_contragarantias.f_del_contragaran_codeu(pscontgar => pscontgar,
                                                              psperson  => psperson,
                                                              pnmovimi  => pnmovimi,
                                                              mensajes  => mensajes);
      --
      RETURN vnum_err;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_del_contragaran_codeu;

   /*************************************************************************
      FUNCTION f_ins_contragaran_codeu

      param in pscontgar : Identificador contragaranta
      param in psperson  : Identificador psperson
      param in pnmovimi  : Nmero de movimiento
      param in mensajes  : t_iax_mensajes
      return             : NUMBER
   *************************************************************************/
   FUNCTION f_ins_contragaran_codeu(pscontgar IN NUMBER,
                                    psperson  IN NUMBER,
                                    pnmovimi  IN NUMBER,
                                    mensajes  IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_MD_CONTRAGARANTIAS.f_ins_contragaran_codeu';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar || ' psperson: ' ||
                                psperson || ' pnmovimi: ' || pnmovimi;
      --
      vnum_err  NUMBER;
      vcimpreso NUMBER;
      vctenedor NUMBER;
      --
   BEGIN
      --
      IF pscontgar IS NULL OR
         psperson IS NULL OR
         pnmovimi IS NULL
      THEN
         --
         RAISE e_param_error;
         --
      END IF;
      -- INI CJMR 05/03/2019
      vnum_err := pac_marcas.f_marcas_validacion(psperson, 3, mensajes);

      IF vnum_err = 1 THEN
         RAISE e_param_error;
      END IF;
      -- FIN CJMR 05/03/2019
      SELECT c.cimpreso,
             c.ctenedor
        INTO vcimpreso,
             vctenedor
        FROM ctgar_contragarantia c
       WHERE c.scontgar = pscontgar
         AND c.nmovimi = (SELECT MAX(nmovimi)
                            FROM ctgar_contragarantia
                           WHERE scontgar = c.scontgar);
      --
      IF NVL(vcimpreso, 0) = 1 OR
         vctenedor != 1
      THEN
         --
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9908864); --El documento ya ha sido impreso
         RAISE e_param_error;
         --
      END IF;
      --
      vnum_err := pac_contragarantias.f_ins_contragaran_codeu(pscontgar => pscontgar,
                                                              psperson  => psperson,
                                                              pnmovimi  => pnmovimi,
                                                              mensajes  => mensajes);
      --
      RETURN vnum_err;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_ins_contragaran_codeu;

   /*************************************************************************
      FUNCTION f_ins_contragaran_doc

      param in pscontgar : Identificador contragaranta
      param in nmovimi   : Nmero de movimiento
      param in iddocgdx  : Id del documento en Gedox
      param in ctipo     : Tipo documento
      param in fcaduci   : Fecha de caducidad
      param in falta     : Fecha de alta
      param in tobserv   : Observaciones
      param in mensajes  : t_iax_mensajes
      return             : NUMBER
   *************************************************************************/
   FUNCTION f_edit_contragaran_doc(pscontgar  IN NUMBER,
                                   pnmovimi   IN NUMBER,
                                   piddocgdx  IN NUMBER,
                                   pctipo     IN NUMBER,
                                   ptobserv   IN VARCHAR2,
                                   ptfilename IN VARCHAR2,
                                   pfcaduci   IN DATE,
                                   mensajes   IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_MD_CONTRAGARANTIAS.f_edit_contragaran_doc';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar || ' pnmovimi: ' ||
                                pnmovimi || ' piddocgdx: ' || piddocgdx ||
                                ' pctipo: ' || pctipo || ' ptobserv: ' ||
                                ptobserv || ' pfcaduci: ' || pfcaduci;
      --
      vnum_err NUMBER;
      --
   BEGIN
      --
      IF pscontgar IS NULL OR
         pnmovimi IS NULL OR
         piddocgdx IS NULL OR
         pctipo IS NULL OR
         ptobserv IS NULL
      THEN
         --
         RAISE e_param_error;
         --
      END IF;
      --
      IF piddocgdx IS NULL
      THEN
         --
         pac_axisgedox.actualiza_gedoxdb(ptfilename, piddocgdx, vnum_err);
         --
      END IF;
      --
      vnum_err := pac_contragarantias.f_edit_contragaran_doc(pscontgar => pscontgar,
                                                             pnmovimi  => pnmovimi,
                                                             piddocgdx => piddocgdx,
                                                             pctipo    => pctipo,
                                                             ptobserv  => ptobserv,
                                                             pfcaduci  => pfcaduci,
                                                             mensajes  => mensajes);
      --
      RETURN vnum_err;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_edit_contragaran_doc;

   /*************************************************************************
      FUNCTION f_ins_contragaran_doc

      param in pscontgar : Identificador contragaranta
      param in nmovimi   : Nmero de movimiento
      param in iddocgdx  : Id del documento en Gedox
      param in ctipo     : Tipo documento
      param in fcaduci   : Fecha de caducidad
      param in falta     : Fecha de alta
      param in tobserv   : Observaciones
      param in mensajes  : t_iax_mensajes
      return             : NUMBER
   *************************************************************************/
   FUNCTION f_ins_contragaran_doc(pscontgar  IN NUMBER,
                                  pnmovimi   IN NUMBER,
                                  piddocgdx  IN NUMBER,
                                  pctipo     IN NUMBER,
                                  ptdescrip  IN VARCHAR2,
                                  ptobserv   IN VARCHAR2,
                                  ptfilename IN VARCHAR2,
                                  pfcaduci   IN DATE,
                                  pfalta     IN DATE,
                                  mensajes   IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_MD_CONTRAGARANTIAS.f_ins_contragaran_doc';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar || ' pnmovimi: ' ||
                                pnmovimi || ' piddocgdx: ' || piddocgdx ||
                                ' pctipo: ' || pctipo || ' ptobserv: ' ||
                                ptobserv || ' pfcaduci: ' || pfcaduci ||
                                ' pfalta: ' || pfalta;
      --
      vnum_err NUMBER;
      vterror  VARCHAR2(200);
      viddoc   NUMBER(8) := 0;
      --
   BEGIN
      --
      IF pscontgar IS NULL OR
         pnmovimi IS NULL OR
         pctipo IS NULL
      THEN
         --
         RAISE e_param_error;
         --
      END IF;
      --
      IF piddocgdx IS NULL
      THEN
         --
         vpasexec := 2;
         pac_axisgedox.grabacabecera(f_user,
                                     ptfilename,
                                     ptdescrip,
                                     1,
                                     1,
                                     pctipo,
                                     vterror,
                                     viddoc);
         --
         IF vterror IS NOT NULL OR
            NVL(viddoc, 0) = 0
         THEN
            vpasexec := 3;
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                                 1,
                                                 1000001,
                                                 vterror);
            RAISE e_object_error;
         END IF;
         --
         pac_axisgedox.actualiza_gedoxdb(ptfilename, viddoc, vterror);
         --
      END IF;
      --
      vpasexec := 4;
      vnum_err := pac_contragarantias.f_ins_contragaran_doc(pscontgar => pscontgar,
                                                            pnmovimi  => pnmovimi,
                                                            piddocgdx => viddoc,
                                                            pctipo    => pctipo,
                                                            ptobserv  => ptobserv,
                                                            pfcaduci  => pfcaduci,
                                                            pfalta    => pfalta,
                                                            mensajes  => mensajes);
      --
      RETURN vnum_err;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_ins_contragaran_doc;

   /*************************************************************************
      FUNCTION f_grabar_contragarantia

      param in mensajes  : t_iax_mensajes
      return             : NUMBER
   *************************************************************************/
   FUNCTION f_grabar_contragarantia(pscontgar     IN NUMBER,
                                    pcasegura     IN NUMBER,
                                    pcbanco       IN NUMBER,
                                    pcclase       IN NUMBER,
                                    pcestado      IN NUMBER,
                                    pcmarca       IN NUMBER,
                                    pctipoveh     IN NUMBER,
                                    pcmoneda      IN VARCHAR2,
                                    pcorigen      IN NUMBER,
                                    ptcausa       IN VARCHAR2,
                                    pcpais        IN NUMBER,
                                    pcprovin      IN NUMBER,
                                    pcpoblac      IN NUMBER,
                                    pctenedor     IN NUMBER,
                                    pctipo        IN NUMBER,
                                    pdocumento    IN VARCHAR2,
                                    pfcertlib     IN DATE,
                                    pfcrea        IN DATE,
                                    pfescritura   IN DATE,
                                    pfexpedic     IN DATE,
                                    pfvencimi     IN DATE,
                                    pfvencimi1    IN DATE,
                                    pfvencimi2    IN DATE,
                                    piasegura     IN NUMBER,
                                    piintcap      IN NUMBER,
                                    piinteres     IN NUMBER,
                                    pivalor       IN NUMBER,
                                    pnempresa     IN NUMBER,
                                    pnmotor       IN NUMBER,
                                    pnnumescr     IN NUMBER,
                                    pnplaca       IN VARCHAR2, 		-- IAXIS-3053 BARTOLO HERRERA - 08/03/2019
                                    pncolor       IN NUMBER,
                                    pnplazo       IN NUMBER,
                                    pnradica      IN NUMBER,
                                    pnserie       IN NUMBER,
                                    psperfide     IN VARCHAR2,  	-- TCS_823 - ACL - 04/03/2019 Se ajusta a campo texto
                                    psperson      IN NUMBER,
                                    ptablas       IN VARCHAR2,
                                    ptauxilia     IN VARCHAR2,
                                    pcimpreso     IN NUMBER,
                                    ptdescripcion IN VARCHAR2,
                                    ptdescripinm  IN VARCHAR2,
                                    ptdireccion   IN VARCHAR2,
                                    ptobsten      IN VARCHAR2,
                                    ptsucursal    IN VARCHAR2,
									ptitcdt       IN VARCHAR2,		-- TCS_826 - ACL - 25/02/2019
                                    pnittit       IN VARCHAR2,		-- TCS_826 - ACL - 25/02/2019
									pcarea        IN NUMBER,        -- TCS_450 - Bartolo Herrera - 07/03/2019
                                    pmodelo       IN DATE, 			-- IAXIS-3053 BARTOLO HERRERA - 08/03/2019
                                    pscontgar_out OUT NUMBER,
                                    pnmovimi_out  OUT NUMBER,
                                    ptasa         IN VARCHAR2, --TCS 309 08/03/2019 AP
                                    piva          IN VARCHAR2, --TCS 309 08/03/2019 AP
                                    PFINIPAG      IN DATE,     --TCS 309 08/03/2019 AP
                                    PFFINPAG      IN DATE,     --TCS 309 08/03/2019 AP
                                    pcpoblacpag   IN NUMBER,   --TCS 309 08/03/2019 AP
                                    PCPROVINPAG   IN NUMBER,   --TCS 309 08/03/2019 AP
                                    PCPOBLACPAR   IN NUMBER,   --TCS 309 08/03/2019 AP
                                    PCPROVINPAR   IN NUMBER,   --TCS 309 08/03/2019 AP
                                    PCPOBLACFIR   IN NUMBER,   --TCS 309 08/03/2019 AP
                                    PCPROVINFIR   IN NUMBER,   --TCS 309 08/03/2019 AP
									pnsinies	  IN NUMBER,		-- TCS_319 - ACL - 13/03/2019
									pporcentaje   IN NUMBER,		-- TCS_319 - ACL - 13/03/2019
									pfoblig		  IN DATE,			-- TCS_319 - ACL - 13/03/2019
									pccuenta	  IN NUMBER, 		-- TCS_319 - ACL - 13/03/2019
									pncuenta	  IN VARCHAR2,		-- TCS_319 - ACL - 13/03/2019
									ptexpagare    IN VARCHAR2,		-- TCS_319 - ACL - 18/03/2019
								    ptexiden	  IN VARCHAR2,		-- TCS_319 - ACL - 18/03/2019
                                    mensajes      IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_MD_CONTRAGARANTIAS.f_grabar_contragarantia';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar || ' pctipo: ' ||
                                pctipo;
      --
      vctenedor NUMBER;
      vcimpreso NUMBER;
      num_err   NUMBER := 0;
	  vcclase   NUMBER;          -- TCS_823 - ACL - 04/03/2019
      vcmoneda  VARCHAR2 (5);	 -- TCS_823 - ACL - 04/03/2019
      vcestado  NUMBER;			 -- TCS_823 - ACL - 04/03/2019
	  vtauxilia VARCHAR2 (2000); -- TCS_823 - ACL - 11/03/2019
      --
   BEGIN
      --
      --Parmetros obligatorios
      IF pcclase IS NULL OR
         pcestado IS NULL OR
         pcmoneda IS NULL OR
         pctenedor IS NULL OR
         pctipo IS NULL OR
         psperson IS NULL
      THEN
         --
         RAISE e_param_error;
         --
      END IF;
      vpasexec := 2;
      --
      IF pcestado = 3 AND
         pscontgar IS NULL
      THEN
         --
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9909782);
         RAISE e_param_error;
         --
      END IF;
      --
      -- INI CJMR 05/03/2019
      num_err := pac_marcas.f_marcas_validacion(psperson, 1, mensajes);

      IF num_err = 1 THEN
         RAISE e_param_error;
      END IF;
      -- FIN CJMR 05/03/2019

      --Valida modificaciones
      IF pscontgar IS NOT NULL
      THEN
         --
       -- Ini TCS_823 - ACL - 28/02/2019 Se agregan validaciones
         SELECT c.ctenedor,
                c.cimpreso, c.cclase, c.cmoneda, c.cestado, c.tauxilia  -- TCS_823 - ACL - 11/03/2019 campo auxilia
           INTO vctenedor,
                vcimpreso, vcclase, vcmoneda, vcestado, vtauxilia   -- TCS_823 - ACL - 11/03/2019
           FROM ctgar_contragarantia c
          WHERE c.scontgar = pscontgar
            AND c.nmovimi = (SELECT MAX(nmovimi)
                               FROM ctgar_contragarantia
                              WHERE scontgar = c.scontgar);
         --
         --Validaciones Tenedor
         IF vctenedor != pctenedor
         THEN
            --
            IF vctenedor IN (1, 9) AND-- IAXIS-3053 BARTOLO HERRERA - 12/03/2019
             --  pctenedor != 3
             pctenedor NOT IN (2, 3, 6, 11, 12)-- IAXIS-3053 BARTOLO HERRERA - 12/03/2019
            THEN
               --
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9908862); --No se puede cambiar a este tenedor la contragaranta
               RAISE e_param_error;
               --
            ELSIF vctenedor = 2 AND
                  pctenedor NOT IN (3, 4)
            THEN
               --
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9908862); --No se puede cambiar a este tenedor la contragaranta
               RAISE e_param_error;
               --
           -- ELSIF vctenedor IN (2, 3) AND
            ELSIF vctenedor IN (3, 5, 6, 7, 11, 12) AND-- IAXIS-3053 BARTOLO HERRERA - 12/03/2019
                  pctenedor != 4
            THEN
               --
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9908862); --No se puede cambiar a este tenedor la contragaranta
               RAISE e_param_error;
               --
            ELSIF vctenedor = 4 AND
                 -- pctenedor NOT IN (5, 6, 8)
                 pctenedor IN (1, 2, 3, 11, 12)   -- IAXIS-3053 BARTOLO HERRERA - 12/03/2019
            THEN
               --
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9908862); --No se puede cambiar a este tenedor la contragaranta
               RAISE e_param_error;
               --
			-- IAXIS-3053 BARTOLO HERRERA - 12/03/2019 inicio

            /* ELSIF vctenedor = 5 AND
                 -- pctenedor != 6
                 pctenedor NOT IN (4, 6, 7)
            THEN
               --
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9908862); --No se puede cambiar a este tenedor la contragaranta
               RAISE e_param_error;
               -- */
			-- IAXIS-3053 BARTOLO HERRERA - 12/03/2019 fin

            ELSIF vctenedor != 1 AND
                  pcestado = 3
            THEN
               --
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9908862); --No se puede cambiar a este tenedor la contragaranta
               RAISE e_param_error;
            --
            ELSIF vctenedor in (6, 7) AND
                  pctenedor != 4
            THEN
               --
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9908862); --No se puede cambiar a este tenedor la contragaranta
               RAISE e_param_error;
               --
			-- Ini TCS_823 - ACL - 11/03/2019 Se agrega validacion estado finalizado
           -- END IF;
               --
            ELSIF vctenedor = 8 AND
                  pctenedor NOT IN (3, 6, 11, 12)-- IAXIS-3053 BARTOLO HERRERA - 12/03/2019
            THEN
               --
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9908862); --No se puede cambiar a este tenedor la contragaranta
               RAISE e_param_error;
            --
			ELSIF vctenedor = 10 AND
                  pctenedor IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 12)-- IAXIS-3053 BARTOLO HERRERA - 12/03/2019
            THEN
               --
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9908862); --No se puede cambiar a este tenedor la contragaranta
               RAISE e_param_error;
            END IF;
			-- Fin TCS_823 - ACL - 11/03/2019
         END IF;
         -- Validacion clase contragaranta
         IF pcclase != vcclase AND
         pscontgar IS NOT NULL
      THEN
         --
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 89906232);
         RAISE e_param_error;
         --
      END IF;

      -- Validacion moneda
         IF pcmoneda != vcmoneda AND
         pscontgar IS NOT NULL
      THEN
         --
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 89906233);
         RAISE e_param_error;
         --
      END IF;
      -- Validacion campo Auxiliar
         IF ptauxilia IS NOT NULL AND
         pscontgar IS NOT NULL
		 -- Ini TCS_823 - ACL - 11/03/2019 Se modifica la validacin
		  THEN
           IF ptauxilia != vtauxilia THEN
             --
             pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 89906234);
             RAISE e_param_error;
           END IF;
		   -- Fin TCS_823 - ACL - 11/03/2019 Se modifica la validacin
      END IF;
      -- Validacion campo Estado contragaranta
	  -- TCS_823 - ACL - 08/03/2019 Se ejusta la condiciÃ³n.
         IF vcestado = 3 AND
        pcestado IN (1, 2)
      THEN
         --
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 89906235);
         RAISE e_param_error;
         --
      END IF;
     -- Fin TCS_823 - ACL - 04/03/2019
         --
         IF NVL(vcimpreso, 0) = 1
         THEN
            --
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9908864); --El documento ya ha sido impreso
            RAISE e_param_error;
            --
         END IF;
         --
      END IF;
      --
      vpasexec := 3;
      --
      IF num_err = 0
      THEN
         num_err := pac_contragarantias.f_ins_contragaran_cab(pscontgar     => pscontgar,
                                                              pnmovimi      => NULL,
                                                              ptdescripcion => ptdescripcion,
                                                              pctipo        => pctipo,
															  pcarea        => pcarea,   -- TCS_450 - Bartolo Herrera - 07/03/2019
                                                              pcclase       => pcclase,
                                                              pcmoneda      => pcmoneda,
                                                              pivalor       => pivalor,
                                                              pfvencimi     => pfvencimi,
                                                              pnempresa     => pnempresa,
                                                              pnradica      => pnradica,
                                                              pfcrea        => NVL(pfcrea, f_sysdate),
                                                              pdocumento    => pdocumento,
                                                              pctenedor     => pctenedor,
                                                              ptobsten      => ptobsten,
                                                              pcestado      => pcestado,
                                                              pcorigen      => pcorigen,
                                                              ptcausa       => ptcausa,
                                                              ptauxilia     => ptauxilia,
                                                              pcimpreso     => pcimpreso,
                                                              pscontgar_out => pscontgar_out,
                                                              pnmovimi_out  => pnmovimi_out,
                                                              mensajes      => mensajes);
      END IF;
      vpasexec := 4;
      IF num_err = 0
      THEN
         num_err := pac_contragarantias.f_ins_contragaran_det(pscontgar  => pscontgar_out,
                                                              pnmovimi   => pnmovimi_out,
                                                              pcpais     => pcpais,
                                                              pfexpedic  => pfexpedic,
                                                              pcbanco    => pcbanco,
                                                              psperfide  => psperfide,
                                                              ptsucursal => ptsucursal,
                                                              piinteres  => piinteres,
                                                              pfvencimi  => pfvencimi,
                                                              pfvencimi1 => pfvencimi1,
                                                              pfvencimi2 => pfvencimi2,
                                                              pnplazo    => pnplazo,
                                                              piasegura  => piasegura,
                                                              piintcap   => piintcap,
                                                              ptitcdt    => ptitcdt,   -- TCS_826 - ACL - 25/02/2019
                                                              pnittit    => pnittit,	-- TCS_826 - ACL - 25/02/2019
                                                              ptasa         => ptasa,        --TCS 309 08/03/2019 AP
                                                              piva          => piva,         --TCS 309 08/03/2019 AP
                                                              PFINIPAG      => PFINIPAG,     --TCS 309 08/03/2019 AP
                                                              PFFINPAG      => PFFINPAG,     --TCS 309 08/03/2019 AP
                                                              pcpoblacpag   => pcpoblacpag,  --TCS 309 08/03/2019 AP
                                                              PCPROVINPAG   => PCPROVINPAG,  --TCS 309 08/03/2019 AP
                                                              PCPOBLACPAR   => PCPOBLACPAR,  --TCS 309 08/03/2019 AP
                                                              PCPROVINPAR   => PCPROVINPAR,  --TCS 309 08/03/2019 AP
                                                              PCPOBLACFIR   => PCPOBLACFIR,  --TCS 309 08/03/2019 AP
                                                              PCPROVINFIR   => PCPROVINFIR,  --TCS 309 08/03/2019 AP
															  pnsinies	 => pnsinies,       -- TCS_319 - ACL - 13/03/2019
                                                              pporcentaje => pporcentaje,   -- TCS_319 - ACL - 13/03/2019
                                                              pfoblig	  => pfoblig,       -- TCS_319 - ACL - 13/03/2019
                                                              pccuenta	  => pccuenta,      -- TCS_319 - ACL - 13/03/2019
                                                              pncuenta	  => pncuenta,	    -- TCS_319 - ACL - 13/03/2019
															  ptexpagare  => ptexpagare,    -- TCS_319 - ACL - 18/03/2019
															  ptexiden	  => ptexiden,		-- TCS_319 - ACL - 18/03/2019
                                                              mensajes   => mensajes);
      END IF;

      IF num_err = 0
      THEN
         num_err := pac_contragarantias.f_ins_contragaran_per(pscontgar => pscontgar_out,
                                                              psperson  => psperson,
                                                              ptablas   => ptablas,
                                                              mensajes  => mensajes);
      END IF;

      IF num_err = 0 AND
         pcclase = 104
      THEN
         num_err := pac_contragarantias.f_ins_contragaran_vh(pscontgar => pscontgar_out,
                                                             pcpais    => pcpais,
                                                             pcprovin  => pcprovin,
                                                             pcpoblac  => pcpoblac,
                                                             pcmarca   => pcmarca,
                                                             pctipo    => pctipoveh,
                                                             pnmotor   => pnmotor,
                                                             pnplaca   => pnplaca,
                                                             pncolor   => pncolor,
                                                             pnserie   => pnserie,
                                                             pcasegura => pcasegura,
															 pmodelo   => pmodelo,		-- IAXIS-3053 - Bartolo Herrera - 08/03/2019
                                                             mensajes  => mensajes);
      END IF;

      IF num_err = 0 AND
         pcclase = 103
      THEN
         num_err := pac_contragarantias.f_ins_contragaran_inm(pscontgar     => pscontgar_out,
                                                              pnnumescr     => pnnumescr,
                                                              pfescritura   => pfescritura,
                                                              ptdescripcion => ptdescripinm,
                                                              ptdireccion   => ptdireccion,
                                                              pcpais        => pcpais,
                                                              pcprovin      => pcprovin,
                                                              pcpoblac      => pcpoblac,
                                                              pfcertlib     => pfcertlib,
                                                              mensajes      => mensajes);
      END IF;

      --Proceso terminado
      IF num_err = 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mens    => mensajes,
                                              tipo    => 2,
                                              nerror  => NULL,
                                              mensaje => 'Contragaranta guardada: ' ||
                                                         pscontgar_out);
         COMMIT;
      ELSE
         RAISE e_param_error;
      END IF;

      --
      RETURN num_err;
      --
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_grabar_contragarantia;

   /*************************************************************************
      FUNCTION f_get_contragaran_mov

      param in pscontgar : Identificador contragaranta
      param in mensajes  : t_iax_mensajes
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_contragaran_mov(pscontgar IN NUMBER,
                                  mensajes  IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      --
      v_cursor SYS_REFCURSOR;
      --
      vpasexec NUMBER;
      vobject  VARCHAR2(200) := 'PAC_MD_CONTRAGARANTIAS.f_get_contragaran_mov';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar;
      --
   BEGIN
      --
      IF pscontgar IS NULL
      THEN
         --
         RAISE e_param_error;
         --
      END IF;
      --
      v_cursor := pac_contragarantias.f_get_contragaran_mov(pscontgar => pscontgar,
                                                            mensajes  => mensajes);
      --
      RETURN v_cursor;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_get_contragaran_mov;

   /*************************************************************************
      FUNCTION f_get_contragaran_pol

      param in pscontgar : Identificador contragaranta
      param in mensajes  : t_iax_mensajes
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_contragaran_pol(pscontgar IN NUMBER,
                                  mensajes  IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      --
      v_cursor SYS_REFCURSOR;
      --
      vpasexec NUMBER;
      vobject  VARCHAR2(200) := 'PAC_MD_CONTRAGARANTIAS.f_get_contragaran_pol';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar;
      --
   BEGIN
      --
      IF pscontgar IS NULL
      THEN
         --
         RAISE e_param_error;
         --
      END IF;
      --
      v_cursor := pac_contragarantias.f_get_contragaran_pol(pscontgar => pscontgar,
                                                            mensajes  => mensajes);
      --
      RETURN v_cursor;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_get_contragaran_pol;

   /*************************************************************************
      FUNCTION f_get_contragaran_code

      param in pscontgar : Identificador contragaranta
      param in mensajes  : t_iax_mensajes
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_contragaran_code(pscontgar IN NUMBER,
                                   mensajes  IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      --
      v_cursor SYS_REFCURSOR;
      --
      vpasexec NUMBER;
      vobject  VARCHAR2(200) := 'PAC_MD_CONTRAGARANTIAS.f_get_contragaran_code';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar;
      --
   BEGIN
      --
      IF pscontgar IS NULL
      THEN
         --
         RAISE e_param_error;
         --
      END IF;
      --
      v_cursor := pac_contragarantias.f_get_contragaran_code(pscontgar => pscontgar,
                                                             mensajes  => mensajes);
      --
      RETURN v_cursor;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_get_contragaran_code;

   /*************************************************************************
      FUNCTION f_get_contragaran_det

      param in pscontgar : Identificador contragaranta
      param in mensajes  : t_iax_mensajes
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_contragaran_det(pscontgar IN NUMBER,
                                  psperson  IN NUMBER DEFAULT NULL,
                                  mensajes  IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      --
      v_cursor SYS_REFCURSOR;
      --
      vpasexec NUMBER;
      vobject  VARCHAR2(200) := 'PAC_MD_CONTRAGARANTIAS.f_get_contragaran_det';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar;
      --
   BEGIN
      --
      IF pscontgar IS NULL
      THEN
         --
         RAISE e_param_error;
         --
      END IF;
      --
      v_cursor := pac_contragarantias.f_get_contragaran_det(pscontgar => pscontgar,
                                                            psperson  => psperson,
                                                            mensajes  => mensajes);
      --
      RETURN v_cursor;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_get_contragaran_det;

   /*************************************************************************
      FUNCTION f_get_contragaran_cab

      param in psperson : Identificador persona
      param in pnradica : Numero de radicado
      param in psseguro : Identificador de seguro
      param in mensajes : t_iax_mensajes
      return            : t_iax_contragaran
   *************************************************************************/
   FUNCTION f_get_contragaran_cab(psperson IN NUMBER,
                                  pnradica IN VARCHAR2,
                                  psseguro IN NUMBER DEFAULT NULL,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_contragaran IS
      --
      t_contragaran t_iax_contragaran;
      --
      vpasexec NUMBER;
      vobject  VARCHAR2(200) := 'PAC_MD_CONTRAGARANTIAS.f_get_contragaran_cab';
      vparam   VARCHAR2(500) := 'psseguro: ' || psseguro || ' psperson: ' ||
                                psperson || ' pnradica: ' || pnradica;
      --
   BEGIN
      --
      t_contragaran := pac_contragarantias.f_get_contragaran_cab(psperson => psperson,
                                                                 pnradica => pnradica,
                                                                 psseguro => psseguro,
                                                                 mensajes => mensajes);
      --
      RETURN t_contragaran;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_get_contragaran_cab;

   /*************************************************************************
      FUNCTION f_get_contragaran_doc

      param in pscontgar : Identificador contragaranta
      param in mensajes  : t_iax_mensajes
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_contragaran_doc(pscontgar IN NUMBER,
                                  mensajes  IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      --
      v_cursor SYS_REFCURSOR;
      --
      vpasexec NUMBER;
      vobject  VARCHAR2(200) := 'pac_md_contragarantias.f_get_contragaran_doc';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar;
      --
   BEGIN
      --
      OPEN v_cursor FOR
         SELECT pac_axisgedox.f_get_descdoc(iddocgdx) descripcion,
                SUBSTR(pac_axisgedox.f_get_filedoc(iddocgdx),
                       INSTR(pac_axisgedox.f_get_filedoc(iddocgdx), '\', -1) + 1,
                       length(pac_axisgedox.f_get_filedoc(iddocgdx))) nombre,
                tobserv,
                falta,
                fcaduci,
				iddocgdx
           FROM ctgar_doc
          WHERE scontgar = pscontgar;
      --
      RETURN v_cursor;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_get_contragaran_doc;

   /*************************************************************************
      FUNCTION f_get_contragaran_cab

      param in psseguro : Identificador de seguro
      param in mensajes : t_iax_mensajes
      return            : t_iax_contragaran
   *************************************************************************/
   FUNCTION f_get_contragaran_seg(psseguro IN NUMBER,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_contragaran IS
      --
      t_contragaran t_iax_contragaran;
      --
      vpasexec NUMBER;
      vobject  VARCHAR2(200) := 'PAC_MD_CONTRAGARANTIAS.f_get_contragaran_seg';
      vparam   VARCHAR2(500) := 'psseguro: ' || psseguro;
      --
   BEGIN
      --
      t_contragaran := pac_contragarantias.f_get_contragaran_seg(psseguro => psseguro,
                                                                 mensajes => mensajes);
      --
      RETURN t_contragaran;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_get_contragaran_seg;
   --
   FUNCTION f_getrelacion_sperson(psperson  IN NUMBER,
                                  ptablas   IN VARCHAR2,
                                  mensajes  IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      --
      v_cursor SYS_REFCURSOR;
      --
      vpasexec NUMBER;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_getrelacion_sperson';
      vparam   VARCHAR2(500) := 'psperson: ' || psperson || ', ptablas: ' || ptablas;
      --
   BEGIN
      --
      IF psperson IS NULL
      THEN
         --
         RAISE e_param_error;
         --
      END IF;
      --
      v_cursor := pac_contragarantias.f_getrelacion_sperson(psperson => psperson,
                                                            ptablas =>ptablas,
                                                            mensajes  => mensajes);
      --
      RETURN v_cursor;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_getrelacion_sperson;

   --Inicio Bartolo Herrera 04-03-2019 ---- IAXIS-2826
   /*************************************************************************
      FUNCTION f_get_contragaran_cab2

      param in psperson : Identificador persona
      param in pnradica : Numero de radicado
      param in psseguro : Identificador de seguro
      param in mensajes : t_iax_mensajes
      return            : t_iax_contragaran
   *************************************************************************/
   FUNCTION f_get_contragaran_cab2(psperson IN NUMBER,
                                  pnradica IN VARCHAR2,
                                  psseguro IN NUMBER DEFAULT NULL,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_contragaran IS
      --
      t_contragaran t_iax_contragaran;
      --
      vpasexec NUMBER;
      vobject  VARCHAR2(200) := 'PAC_MD_CONTRAGARANTIAS.f_get_contragaran_cab';
      vparam   VARCHAR2(500) := 'psseguro: ' || psseguro || ' psperson: ' ||
                                psperson || ' pnradica: ' || pnradica;
      --
   BEGIN
      --
      t_contragaran := pac_contragarantias.f_get_contragaran_cab2(psperson => psperson,
                                                                 pnradica => pnradica,
                                                                 psseguro => psseguro,
                                                                 mensajes => mensajes);
      --
      RETURN t_contragaran;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_get_contragaran_cab2;
   --Fin Bartolo Herrera 04-03-2019 ---- IAXIS-2826

END pac_md_contragarantias;
/