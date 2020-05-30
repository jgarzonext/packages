create or replace PACKAGE "PAC_CONTRAGARANTIAS" IS
   /******************************************************************************
      NOMBRE:    pac_contragarantias
      PROPSITO: Funciones para contragarantias

      REVISIONES:
      Ver        Fecha        Autor             Descripcin
      ---------  ----------  ---------------  ------------------------------------
      1.0        02/03/2016  JAE              1. Creacinn del objeto.
      2.0        25/02/2019  ACL              2. Se agrega parmetros a la funcin f_ins_contragaran_det
	  3.0        14/03/2019  ACL              3. TCS_309: Se agrega parametros a la funcion f_ins_contragaran_det
	  4.0        18/03/2019  ACL              4. TCS_309: Se agrega parametros para texto a la funcion f_ins_contragaran_det
   ******************************************************************************/

   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

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
   FUNCTION f_edit_contragaran_doc(pscontgar IN NUMBER,
                                   pnmovimi  IN NUMBER,
                                   piddocgdx IN NUMBER,
                                   pctipo    IN NUMBER,
                                   ptobserv  IN VARCHAR2,
                                   pfcaduci  IN DATE,
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
   FUNCTION f_ins_contragaran_doc(pscontgar IN NUMBER,
                                  pnmovimi  IN NUMBER,
                                  piddocgdx IN NUMBER,
                                  pctipo    IN NUMBER,
                                  ptobserv  IN VARCHAR2,
                                  pfcaduci  IN DATE,
                                  pfalta    IN DATE,
                                  mensajes  IN OUT t_iax_mensajes)
      RETURN NUMBER;

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
      FUNCTION f_ins_contragaran_inm

      param in pscontgar     : Identificador contragaranta
      param in psinmueble    : Identificador nico / Secuencia del inmueble
      param in pnnumescr     : Numero de la escritura publica
      param in pfescritura   : Fecha de la escritura
      param in ptdescripcion : Descripcin general
      param in ptdireccion   : Direccin del inmueble
      param in pcpais        : Pais
      param in pcprovin      : Codigo de Provincia
      param in pcpoblac      : Municipio
      param in pfcertlib     : Certificado libertad
      param in mensajes      : t_iax_mensajes
      return                 : NUMBER
   *************************************************************************/
   FUNCTION f_ins_contragaran_inm(pscontgar     IN NUMBER,
                                  pnnumescr     IN NUMBER,
                                  pfescritura   IN DATE,
                                  ptdescripcion IN VARCHAR2,
                                  ptdireccion   IN VARCHAR2,
                                  pcpais        IN NUMBER,
                                  pcprovin      IN NUMBER,
                                  pcpoblac      IN NUMBER,
                                  pfcertlib     IN DATE,
                                  mensajes      IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_ins_contragaran_vh

      param in pscontgar : Identificador contragaranta
      param in psvehiculo: Identificador vehculo
      param in pcpoblac  : Pas
      param in pcpoblac  : Provincia
      param in pcpoblac  : Poblacin
      param in pcmarca   : Marca
      param in pctipo    : Tipo
      param in pnmotor   : Numero de motor
      param in pnplaca   : Numero de placa
      param in pncolor   : Color
      param in pnserie   : Serie
      param in pcasegura : Asegura
      param in mensajes  : t_iax_mensajes
      return             : NUMBER
   *************************************************************************/
   FUNCTION f_ins_contragaran_vh(pscontgar IN NUMBER,
                                 pcpais    IN NUMBER,
                                 pcprovin  NUMBER,
                                 pcpoblac  IN NUMBER,
                                 pcmarca   IN NUMBER,
                                 pctipo    IN NUMBER,
                                 pnmotor   IN VARCHAR2,
                                 pnplaca   IN VARCHAR2,
                                 pncolor   IN NUMBER,
                                 pnserie   IN NUMBER,
                                 pcasegura IN NUMBER,
								 pmodelo IN DATE, 			-- IAXIS-3053 BARTOLO HERRERA - 08/03/2019
                                 mensajes  IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_ins_contragaran_per

      param in pscontgar : Identificador contragaranta
      param in psperson  : Identificador psperson
      param in ptablas   : Tablas Reales/Estudio
      param in mensajes  : t_iax_mensajes
      return             : NUMBER
   *************************************************************************/
   FUNCTION f_ins_contragaran_per(pscontgar IN NUMBER,
                                  psperson  IN NUMBER,
                                  ptablas   IN VARCHAR2,
                                  mensajes  IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_ins_contragaran_det

      param in mensajes  : t_iax_mensajes
      return             : NUMBER
   *************************************************************************/
   FUNCTION f_ins_contragaran_det(pscontgar  IN NUMBER,
                                  pnmovimi   IN NUMBER,
                                  pcpais     IN NUMBER,
                                  pfexpedic  IN DATE,
                                  pcbanco    IN NUMBER,
                                  psperfide  IN NUMBER,
                                  ptsucursal IN VARCHAR2,
                                  piinteres  IN NUMBER,
                                  pfvencimi  IN DATE,
                                  pfvencimi1 IN DATE,
                                  pfvencimi2 IN DATE,
                                  pnplazo    IN NUMBER,
                                  piasegura  IN NUMBER,
                                  piintcap   IN NUMBER,
				  ptitcdt    IN VARCHAR2,   -- TCS_826 - ACL - 25/02/2019
                                  pnittit    IN VARCHAR2,	-- TCS_826 - ACL - 25/02/2019
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
								  pnsinies	 IN NUMBER,		    -- TCS_319 - ACL - 13/03/2019
                                  pporcentaje  IN NUMBER,		-- TCS_319 - ACL - 13/03/2019
                                  pfoblig	  IN DATE,			-- TCS_319 - ACL - 13/03/2019
                                  pccuenta	  IN NUMBER, 		-- TCS_319 - ACL - 13/03/2019
                                  pncuenta	  IN VARCHAR2,		-- TCS_319 - ACL - 13/03/2019
								  ptexpagare  IN VARCHAR2,		-- TCS_319 - ACL - 18/03/2019
								  ptexiden	  IN VARCHAR2,		-- TCS_319 - ACL - 18/03/2019
                                  mensajes   IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_ins_contragaran_cab

      param in mensajes  : t_iax_mensajes
      return             : NUMBER
   *************************************************************************/
   FUNCTION f_ins_contragaran_cab(pscontgar     IN NUMBER,
                                  pnmovimi      IN NUMBER,
                                  ptdescripcion IN VARCHAR2,
                                  pctipo        IN NUMBER,
								  pcarea        IN NUMBER,        -- TCS_450 - Bartolo Herrera - 07/03/2019
                                  pcclase       IN NUMBER,
                                  pcmoneda      IN VARCHAR2,
                                  pivalor       IN NUMBER,
                                  pfvencimi     IN DATE,
                                  pnempresa     IN NUMBER,
                                  pnradica      IN NUMBER,
                                  pfcrea        IN DATE,
                                  pdocumento    IN VARCHAR2,
                                  pctenedor     IN NUMBER,
                                  ptobsten      IN VARCHAR2,
                                  pcestado      IN NUMBER,
                                  pcorigen      IN NUMBER,
                                  ptcausa       IN VARCHAR2,
                                  ptauxilia     IN VARCHAR2,
                                  pcimpreso     IN NUMBER,
                                  pscontgar_out OUT NUMBER,
                                  pnmovimi_out  OUT NUMBER,
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
   --INI TCS 309 08/03/2019 AP
   FUNCTION f_getPagareCartera (pscontgar  IN NUMBER)
      RETURN varchar2;
   --FIN TCS 309 08/03/2019 AP

END pac_contragarantias;
/