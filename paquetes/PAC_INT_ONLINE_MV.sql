--------------------------------------------------------
--  DDL for Package PAC_INT_ONLINE_MV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_INT_ONLINE_MV" AUTHID CURRENT_USER IS

   FUNCTION f_obtener_dni (
      pctipdoc    IN   VARCHAR2,
      pdocident   IN   VARCHAR2,
	  ptidenti    OUT  NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_crea_usuario (
      puser     IN   VARCHAR2,
      pnombre   IN   VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_borra_usuario (
      puser   IN   VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_crea_dsi (
      puser   IN   VARCHAR2)
      RETURN NUMBER;

/*   FUNCTION insertar_persona (
      p_out      IN       Pac_Xml_Mv.rinfpersona_out,
      p_tfnos    IN       Pac_Xml_Mv.ttelefonos,
      psseguro   IN       NUMBER,
      psperson   OUT      NUMBER)
      RETURN NUMBER;

FUNCTION insertar_prestamo(pprestamo_out IN Pac_Xml_Mv.rdatosprestamo_out,
    ptitulares_out IN Pac_Xml_Mv.ttitulares_out,
	pcuadro_out IN Pac_Xml_Mv.tcuadroamort_out)
	RETURN NUMBER;
*/
   FUNCTION f_pol_error (
      psseguro   IN   NUMBER,
      pnrecibo   IN   NUMBER,
      pctiperr   IN   NUMBER)
      RETURN NUMBER;

/*   FUNCTION conectar_host (
      p_empleado   IN       VARCHAR2,
      p_out        OUT      Pac_Xml_Mv.rlogon_out,
      p_error      OUT      VARCHAR2)
      RETURN NUMBER;

   FUNCTION buscar_personas (
      p_posicionamiento   IN OUT   VARCHAR2,
      p_formato           IN       VARCHAR2,
      p_empleado          IN       VARCHAR2,
      p_centroorigen      IN       VARCHAR2,
      p_sip               IN       VARCHAR2,
      p_docident          IN       VARCHAR2,
      p_nombre            IN       VARCHAR2,
      p_out               OUT      Pac_Xml_Mv.tpersonas,
      p_error             OUT      VARCHAR2)
      RETURN NUMBER;

   FUNCTION buscar_infpersonas (
      p_empleado       IN       VARCHAR2,
      p_centroorigen   IN       VARCHAR2,
      p_sip            IN       VARCHAR2,
      p_out            OUT      Pac_Xml_Mv.rinfpersona_out,
      p_tfnos          OUT      Pac_Xml_Mv.ttelefonos,
      p_error          OUT      VARCHAR2)
      RETURN NUMBER;
*/
   FUNCTION alta_poliza_host (
      p_empleado       IN       VARCHAR2,
      p_centroorigen   IN       VARCHAR2,
      p_foperacion     IN       DATE,
      p_sseguro        IN       NUMBER,
      p_tipocobro      IN       NUMBER,
	  p_tipoerror	   OUT		NUMBER,
      p_error          OUT      VARCHAR2)
      RETURN NUMBER;

   FUNCTION adeudo_recibo_host (
      p_formato        IN       VARCHAR2,
      p_empleado       IN       VARCHAR2,
      p_centroorigen   IN       VARCHAR2,
      p_foperacion     IN       DATE,
      p_nrecibo        IN       NUMBER,
      p_tipocobro      IN       NUMBER,
      p_aut            OUT      NUMBER,
      p_error          OUT      VARCHAR2)
      RETURN NUMBER;

FUNCTION cambio_cuenta_bancaria(p_empleado IN VARCHAR2,
  p_centroOrigen IN VARCHAR2, p_fOperacion IN DATE, p_sseguro IN NUMBER,
  p_cccAnt IN VARCHAR2, p_cccNou IN VARCHAR2, p_tipoerror OUT NUMBER,
  p_error OUT VARCHAR2) RETURN NUMBER;

/*FUNCTION datos_prestamo(p_empleado IN VARCHAR2, p_fOperacion IN DATE,
     p_contrato IN VARCHAR2, pdatospres_out OUT Pac_Xml_Mv.rdatosprestamo_out,
	 ptitulares_out OUT Pac_Xml_Mv.ttitulares_out,
	 pcuadro_out OUT Pac_Xml_Mv.tcuadroamort_out, p_tipoerror OUT NUMBER,
	 p_error OUT VARCHAR2) RETURN NUMBER;
*/
   FUNCTION f_borrar_personas (
      psperson   IN   NUMBER)
      RETURN NUMBER;

   FUNCTION f_borrar_persona_seguro (
      psseguro   IN   NUMBER)
      RETURN NUMBER;

   FUNCTION f_persona_extranjera (
      psector   IN   VARCHAR2,
	  pnacionalidad  IN  VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION f_persona_no_operativa (
      poperativa   IN   VARCHAR2)
      RETURN BOOLEAN;

FUNCTION f_tipo_amort_no_permitida (ptipoamort IN NUMBER, psproduc IN NUMBER)
     RETURN BOOLEAN;

FUNCTION f_tipo_prestamo_no_coincide (ptipoprest IN NUMBER, psproduc IN NUMBER,
     ptipoamort IN NUMBER) RETURN BOOLEAN;

FUNCTION f_datosprest_dif (pctapres IN VARCHAR2,
     pctipamort IN NUMBER, pctipint IN NUMBER, pctippres IN NUMBER) RETURN BOOLEAN;

/*FUNCTION f_titulares_dif_mismo_prestamo (pctapres IN VARCHAR2,
     ptitulares IN Pac_Xml_Mv.ttitulares_out) RETURN BOOLEAN;
*/
FUNCTION f_domicilio_no_valido (ptipodomicilio IN VARCHAR2) RETURN BOOLEAN;

FUNCTION inserta_pob_cp_extranjero (pcprovin IN NUMBER,
                                    ptpoblac IN VARCHAR2,
     pcpoblac OUT NUMBER) RETURN NUMBER;

FUNCTION f_ins_solprestcuadro (psinterf IN NUMBER, pssolici IN NUMBER) RETURN NUMBER;


END Pac_Int_Online_Mv;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_INT_ONLINE_MV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_INT_ONLINE_MV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_INT_ONLINE_MV" TO "PROGRAMADORESCSI";
