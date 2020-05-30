--------------------------------------------------------
--  DDL for Package PAC_MD_CONTRAGARANTIAS
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "AXIS"."PAC_MD_CONTRAGARANTIAS" IS
   /******************************************************************************
      NOMBRE:    pac_md_contragarantias
      PROPSITO: Funciones para contragarantias

      REVISIONES:
      Ver        Fecha        Autor             Descripcin
      ---------  ----------  ---------------  ------------------------------------
      1.0        02/03/2016  JAE              1. Creacinn del objeto.
	  2.0        25/02/2019  ACL              2. TCS_826: Se agrega parmetros a la funcin f_grabar_contragarantia
	  3.0        04/03/2019  ACL              3. TCS_823: Se ajusta parmetro SPERFIDE en la funcin f_grabar_contragarantia
	  4.0        14/03/2019  ACL              4. TCS_309: Se agrega parametros a la funcion f_grabar_contragarantia
	  5.0        18/03/2019  ACL              5. TCS_309: Se agrega parametros para texto a la funcion f_grabar_contragarantia
   ******************************************************************************/

   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

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
      RETURN NUMBER;

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
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_del_contragaran_codeu

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
      RETURN NUMBER;

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
      RETURN NUMBER;

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
      RETURN NUMBER;

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
      RETURN NUMBER;

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
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_get_contragaran_mov

      param in pscontgar : Identificador contragaranta
      param in mensajes  : t_iax_mensajes
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_contragaran_mov(pscontgar IN NUMBER,
                                  mensajes  IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /*************************************************************************
      FUNCTION f_get_contragaran_pol

      param in pscontgar : Identificador contragaranta
      param in mensajes  : t_iax_mensajes
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_contragaran_pol(pscontgar IN NUMBER,
                                  mensajes  IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /*************************************************************************
      FUNCTION f_get_contragaran_code

      param in pscontgar : Identificador contragaranta
      param in mensajes  : t_iax_mensajes
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_contragaran_code(pscontgar IN NUMBER,
                                   mensajes  IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /*************************************************************************
      FUNCTION f_get_contragaran_det

      param in pscontgar : Identificador contragaranta
      param in mensajes  : t_iax_mensajes
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_contragaran_det(pscontgar IN NUMBER,
                                  psperson  IN NUMBER DEFAULT NULL,
                                  mensajes  IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

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
      RETURN t_iax_contragaran;

   /*************************************************************************
      FUNCTION f_get_contragaran_doc

      param in pscontgar : Identificador contragaranta
      param in mensajes  : t_iax_mensajes
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_contragaran_doc(pscontgar IN NUMBER,
                                  mensajes  IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /*************************************************************************
      FUNCTION f_get_contragaran_cab

      param in psseguro : Identificador de seguro
      param in mensajes : t_iax_mensajes
      return            : t_iax_contragaran
   *************************************************************************/
   FUNCTION f_get_contragaran_seg(psseguro IN NUMBER,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_contragaran;
   --
   FUNCTION f_getrelacion_sperson(psperson  IN NUMBER,
                                  ptablas   IN VARCHAR2,
                                  mensajes  IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

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
      RETURN t_iax_contragaran;
	--Fin Bartolo Herrera 04-03-2019 ---- IAXIS-2826

END pac_md_contragarantias;

/