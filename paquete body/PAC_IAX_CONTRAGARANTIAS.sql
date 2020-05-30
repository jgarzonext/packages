create or replace PACKAGE BODY "PAC_IAX_CONTRAGARANTIAS" IS
   /******************************************************************************
      NOMBRE:    pac_iax_contragarantias
      PROPSITO: Funciones para contragarantias

      REVISIONES:
      Ver        Fecha        Autor             Descripcin
      ---------  ----------  ---------------  ------------------------------------
      1.0        02/03/2016  JAE              1. Creacinn del objeto.
      2.0        25/02/2019  ACL              2. Se agrega parmetros a la funcin f_grabar_contragarantia.
	  3.0        04/03/2019  ACL              2. Se ajusta parmetro SPERFIDE en la funcin f_grabar_contragarantia
	  4.0        14/03/2019  ACL              4. TCS_309: Se agrega parametros a la funcion f_grabar_contragarantia
	  5.0        18/03/2019  ACL              5. TCS_309: Se agrega parametros de texto a la funcion f_grabar_contragarantia
   ******************************************************************************/

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
                                  mensajes  OUT t_iax_mensajes) RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'pac_iax_contragarantias.f_ins_contragaran_pol';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar || ' psseguro: ' ||
                                psseguro || ' pnmovimi: ' || pnmovimi ||
                                ' ptablas: ' || ptablas;
      --
      vnum_err NUMBER;
      --
   BEGIN
      --
      vnum_err := pac_md_contragarantias.f_ins_contragaran_pol(pscontgar => pscontgar,
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
                                  mensajes  OUT t_iax_mensajes) RETURN NUMBER IS
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
                                    mensajes  OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'pac_iax_contragarantias.f_del_contragaran_codeu';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar || ' psperson: ' ||
                                psperson || ' pnmovimi: ' || pnmovimi;
      --
      vnum_err NUMBER;
      --
   BEGIN
      --
      vnum_err := pac_md_contragarantias.f_del_contragaran_codeu(pscontgar => pscontgar,
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
                                    mensajes  OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'pac_iax_contragarantias.f_ins_contragaran_codeu';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar || ' psperson: ' ||
                                psperson || ' pnmovimi: ' || pnmovimi;
      --
      vnum_err NUMBER;
      --
   BEGIN
      --
      vnum_err := pac_md_contragarantias.f_ins_contragaran_codeu(pscontgar => pscontgar,
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
                                   mensajes   OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'pac_iax_contragarantias.f_edit_contragaran_doc';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar || ' pnmovimi: ' ||
                                pnmovimi || ' piddocgdx: ' || piddocgdx ||
                                ' pctipo: ' || pctipo || ' ptobserv: ' ||
                                ptobserv || ' pfcaduci: ' || pfcaduci;
      --
      vnum_err NUMBER;
      --
   BEGIN
      --
      vnum_err := pac_md_contragarantias.f_edit_contragaran_doc(pscontgar  => pscontgar,
                                                                pnmovimi   => pnmovimi,
                                                                piddocgdx  => piddocgdx,
                                                                pctipo     => pctipo,
                                                                ptobserv   => ptobserv,
                                                                ptfilename => ptfilename,
                                                                pfcaduci   => pfcaduci,
                                                                mensajes   => mensajes);
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
                                  mensajes   OUT t_iax_mensajes) RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'pac_iax_contragarantias.f_ins_contragaran_doc';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar || ' pnmovimi: ' ||
                                pnmovimi || ' piddocgdx: ' || piddocgdx ||
                                ' pctipo: ' || pctipo || ' ptobserv: ' ||
                                ptobserv || ' pfcaduci: ' || pfcaduci ||
                                ' pfalta: ' || pfalta;
      --
      vnum_err NUMBER;
      --
   BEGIN
      --
      vnum_err := pac_md_contragarantias.f_ins_contragaran_doc(pscontgar  => pscontgar,
                                                               pnmovimi   => pnmovimi,
                                                               piddocgdx  => piddocgdx,
                                                               pctipo     => pctipo,
                                                               ptdescrip  => ptdescrip,
                                                               ptobserv   => ptobserv,
                                                               ptfilename => ptfilename,
                                                               pfcaduci   => pfcaduci,
                                                               pfalta     => pfalta,
                                                               mensajes   => mensajes);
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
                                    PCPROVINFIR    IN NUMBER,  --TCS 309 08/03/2019 AP
									pnsinies	  IN NUMBER,		-- TCS_319 - ACL - 13/03/2019
									pporcentaje   IN NUMBER,		-- TCS_319 - ACL - 13/03/2019
									pfoblig		  IN DATE,			-- TCS_319 - ACL - 13/03/2019
									pccuenta	  IN NUMBER, 		-- TCS_319 - ACL - 13/03/2019
									pncuenta	  IN VARCHAR2,		-- TCS_319 - ACL - 13/03/2019
									ptexpagare    IN VARCHAR2,		-- TCS_319 - ACL - 18/03/2019
								    ptexiden	  IN VARCHAR2,		-- TCS_319 - ACL - 18/03/2019
                                    mensajes      OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'pac_iax_contragarantias.f_grabar_contragarantia';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar || ' pctipo: ' ||
                                pctipo;
      --
      num_err NUMBER;
      --
   BEGIN
      --
      num_err := pac_md_contragarantias.f_grabar_contragarantia(pscontgar     => pscontgar,
                                                                pcasegura     => pcasegura,
                                                                pcbanco       => pcbanco,
                                                                pcclase       => pcclase,
                                                                pcestado      => pcestado,
                                                                pcmarca       => pcmarca,
                                                                pctipoveh     => pctipoveh,
                                                                pcmoneda      => pcmoneda,
                                                                pcorigen      => pcorigen,
                                                                ptcausa       => ptcausa,
                                                                pcpais        => pcpais,
                                                                pcprovin      => pcprovin,
                                                                pcpoblac      => pcpoblac,
                                                                pctenedor     => pctenedor,
                                                                pctipo        => pctipo,
                                                                pdocumento    => pdocumento,
                                                                pfcertlib     => pfcertlib,
                                                                pfcrea        => pfcrea,
                                                                pfescritura   => pfescritura,
                                                                pfexpedic     => pfexpedic,
                                                                pfvencimi     => pfvencimi,
                                                                pfvencimi1    => pfvencimi1,
                                                                pfvencimi2    => pfvencimi2,
                                                                piasegura     => piasegura,
                                                                piintcap      => piintcap,
                                                                piinteres     => piinteres,
                                                                pivalor       => pivalor,
                                                                pnempresa     => pnempresa,
                                                                pnmotor       => pnmotor,
                                                                pnnumescr     => pnnumescr,
                                                                pnplaca       => pnplaca,
                                                                pncolor       => pncolor,
                                                                pnplazo       => pnplazo,
                                                                pnradica      => pnradica,
                                                                pnserie       => pnserie,
                                                                psperfide     => psperfide,
                                                                psperson      => psperson,
                                                                ptablas       => ptablas,
                                                                ptauxilia     => ptauxilia,
                                                                pcimpreso     => pcimpreso,
                                                                ptdescripcion => ptdescripcion,
                                                                ptdescripinm  => ptdescripinm,
                                                                ptdireccion   => ptdireccion,
                                                                ptobsten      => ptobsten,
                                                                ptsucursal    => ptsucursal,
																ptitcdt       => ptitcdt,			-- TCS_826 - ACL - 25/02/2019
																pnittit       => pnittit,    		-- TCS_826 - ACL - 25/02/2019
																pcarea       => pcarea,    		    -- TCS_450 - Bartolo Herrera - 07/03/2019
                                                                pmodelo       => pmodelo,    		    -- IAXIS-3053 - Bartolo Herrera - 08/03/2019
                                                                pscontgar_out => pscontgar_out,
                                                                pnmovimi_out  => pnmovimi_out,
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
																pnsinies	  => pnsinies,      -- TCS_319 - ACL - 13/03/2019
                                                                pporcentaje   => pporcentaje,   -- TCS_319 - ACL - 13/03/2019
                                                                pfoblig		  => pfoblig,       -- TCS_319 - ACL - 13/03/2019
                                                                pccuenta	  => pccuenta,      -- TCS_319 - ACL - 13/03/2019
                                                                pncuenta	  => pncuenta,      -- TCS_319 - ACL - 13/03/2019
																ptexpagare    => ptexpagare,    -- TCS_319 - ACL - 18/03/2019
															    ptexiden	  => ptexiden,		-- TCS_319 - ACL - 18/03/2019
                                                                mensajes      => mensajes);
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
                                  mensajes  OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      --
      v_cursor SYS_REFCURSOR;
      --
      vpasexec NUMBER;
      vobject  VARCHAR2(200) := 'pac_iax_contragarantias.f_get_contragaran_mov';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar;
      --
   BEGIN
      --
      v_cursor := pac_md_contragarantias.f_get_contragaran_mov(pscontgar => pscontgar,
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
                                  mensajes  OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      --
      v_cursor SYS_REFCURSOR;
      --
      vpasexec NUMBER;
      vobject  VARCHAR2(200) := 'pac_iax_contragarantias.f_get_contragaran_pol';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar;
      --
   BEGIN
      --
      v_cursor := pac_md_contragarantias.f_get_contragaran_pol(pscontgar => pscontgar,
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
                                   mensajes  OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      --
      v_cursor SYS_REFCURSOR;
      --
      vpasexec NUMBER;
      vobject  VARCHAR2(200) := 'pac_iax_contragarantias.f_get_contragaran_code';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar;
      --
   BEGIN
      --
      v_cursor := pac_md_contragarantias.f_get_contragaran_code(pscontgar => pscontgar,
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
                                  mensajes  OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      --
      v_cursor SYS_REFCURSOR;
      --
      vpasexec NUMBER;
      vobject  VARCHAR2(200) := 'pac_iax_contragarantias.f_get_contragaran_det';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar;
      --
   BEGIN
      --
      v_cursor := pac_md_contragarantias.f_get_contragaran_det(pscontgar => pscontgar,
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
                                  mensajes OUT t_iax_mensajes)
      RETURN t_iax_contragaran IS
      --
      t_contragaran t_iax_contragaran;
      --
      vpasexec NUMBER;
      vobject  VARCHAR2(200) := 'pac_iax_contragarantias.f_get_contragaran_cab';
      vparam   VARCHAR2(500) := 'psseguro: ' || psseguro || ' psperson: ' ||
                                psperson || ' pnradica: ' || pnradica;
      --
   BEGIN
      --
      t_contragaran := pac_md_contragarantias.f_get_contragaran_cab(psperson => psperson,
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
                                  mensajes  OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      --
      v_cursor SYS_REFCURSOR;
      --
      vpasexec NUMBER;
      vobject  VARCHAR2(200) := 'pac_iax_contragarantias.f_get_contragaran_doc';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar;
      --
   BEGIN
      --
      v_cursor := pac_md_contragarantias.f_get_contragaran_doc(pscontgar => pscontgar,
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
   END f_get_contragaran_doc;

   /*************************************************************************
      FUNCTION f_get_contragaran_cab

      param in psseguro : Identificador de seguro
      param in mensajes : t_iax_mensajes
      return            : t_iax_contragaran
   *************************************************************************/
   FUNCTION f_get_contragaran_seg(psseguro IN NUMBER,
                                  mensajes OUT t_iax_mensajes)
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
                                  mensajes  OUT t_iax_mensajes)
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
      v_cursor := pac_md_contragarantias.f_getrelacion_sperson(psperson => psperson,
                                                               ptablas => ptablas,
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
                                  mensajes OUT t_iax_mensajes)
      RETURN t_iax_contragaran IS
      --
      t_contragaran t_iax_contragaran;
      --
      vpasexec NUMBER;
      vobject  VARCHAR2(200) := 'pac_iax_contragarantias.f_get_contragaran_cab';
      vparam   VARCHAR2(500) := 'psseguro: ' || psseguro || ' psperson: ' ||
                                psperson || ' pnradica: ' || pnradica;
      --
   BEGIN
      --
      t_contragaran := pac_md_contragarantias.f_get_contragaran_cab2(psperson => psperson,
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

END pac_iax_contragarantias;
/