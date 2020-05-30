--------------------------------------------------------
--  DDL for Package PAC_IAX_SIMULACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_SIMULACIONES" AS
   /******************************************************************************
   NOMBRE: AXIS_D37.PAC_IAX_SIMULACIONES
   PROPÓSITO: Funciones para simulación

   REVISIONES:
   Ver Fecha Autor Descripción
   --------- ---------- -------- ------------------------------------
   1.0 19/12/2007 ACC 1. Creación del package.
   2.0 25/06/2009 AMC 2. Se añade la función f_actmodtom bug 9642
   3.0 05/11/2009 NMM 3. 10093: CRE - Afegir filtre per RAM en els cercadors.
   4.0 22/06/2010 PFA 4. 14599: CEM301 - Ajuste pantalla simulación (Rentas)
   5.0 14/12/2010 XPL 5. 16799: CRT003 - Alta rapida poliza correduria
   6.0 08/09/2011 APD 6. 0018848: LCOL003 - Vigencia fecha de tarifa
   7.0 02/12/2011 AMC 7. Bug 20307/99655 - Se a�aden nuevos parametros a las funciones f_grabaasegurado y f_gravatomadores
   8.0 04/06/2013 JDS 8. 0026923: LCOL - TEC - Revisi�n Q-Trackers Fase 3A
   9.0 12/08/2013 RCL 9. 0027610: LCOL - AUT - No borrar simulaci�n cuando se pasa a propuesta (f_grabarsimulacion_sinvalidar)
   10.0 05/09/2013 JSV 10. 0027955: LCOL_T031- QT GUI de Fase 3
   11.0 28/01/2014 JTT 11. 0027429: Afegim la funcio F_rechazar_simul
   12.0 03/02/2014 JTT 12. 0027430: A�adir al filtro de busqueda de simulaciones el tomador y la fecha de cotizacion
   ******************************************************************************/
   simulacion     ob_iax_poliza;   --Objeto simulación original en carrega de datos
   isconsultsimul BOOLEAN := FALSE;
   isparammismo_aseg BOOLEAN := FALSE;   -- Indica si prenedor es l'assegurat
   contracsimul   BOOLEAN := FALSE;   -- Indica si pasamos de una simulación a una contratación
   --BUG9427-02042009-XVM
   islimpiartemporales BOOLEAN := FALSE;   -- Bug 18848 - APD - 08/09/2011

   /*************************************************************************
   Recupera el riesgo asegurado indicado por el parametro
   param in pnriesgo : número de riesgo
   param out : mensajes de error
   return : objeto asegurado
   *************************************************************************/
   FUNCTION f_get_asegurado(
      pnriesgo IN NUMBER,
      psperson IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_asegurados;

   /*************************************************************************
   Graba el asegurado
   param in psperson : número de persona
   param in pcsexper : sexo de la persona
   param in pfnacimi : fecha nacimiento
   param in pnnumnif : número identificación persona
   param in tnombre : nombre de la persona
   param in tnombre1 : primer nombre de la persona
   param in tnombre2 : segundo nombre de la persona
   param in tapelli1 : primer apellido
   param in tapelli2 : segundo apellido
   param in pctipide : Tipo de identificación persona V.F. 672
   param in pctipper : Tipo de persona V.F. 85
   param out : mensajes de error
   return : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabaasegurados(
      psperson IN NUMBER,
      pcsexper IN NUMBER,
      pfnacimi IN DATE,
      pnnumnif IN VARCHAR2,
      ptnombre IN VARCHAR2,
      ptnombre1 IN VARCHAR2,
      ptnombre2 IN VARCHAR2,
      ptapelli1 IN VARCHAR2,
      ptapelli2 IN VARCHAR2,
      pctipide IN NUMBER,
      pctipper IN NUMBER,
      pcestciv IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Graba la simulación
   param out : mensajes de error
   return : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabarsimulacion(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Graba la simulación sin validciones
   param out : mensajes de error
   return : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabarsimulacion_sinvalidar(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Elimina un riesgo
   param in pnriesgo : número de riesgo
   param out mensajes : mensajes de error
   return : 0 todo ha sido correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_eliminariesgo(pnriesgo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-- BUG 14599 - PFA - Ajuste pantalla simulación (Rentas)
 /*************************************************************************
 Elimina un asegurado
 param in sperson : identificador del asegurado
 param out mensajes : mensajes de error
 return : 0 todo ha sido correcto
 1 ha habido un error
 *************************************************************************/
   FUNCTION f_eliminaaseg(psperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

--Fi BUG 14599 - PFA - Ajuste pantalla simulación (Rentas)

   /*************************************************************************
   Recupera el número de solicitud
   param out mensajes : mensajes de error
   return : número de solicitud
   *************************************************************************/
   FUNCTION f_get_codigosimul(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Borra los registros de las tablas est
   *************************************************************************/
   PROCEDURE limpiartemporales;

/************************************************************************
 INICI CONSULTA
************************************************************************/

   /*************************************************************************
   Devuelve las simulaciones que cumplan con el criterio de selección
   param in psproduc : código de producto
   param in psolicit : número de solicitud
   param in ptriesgo : descripción del riesgo
   param out mensajes : mensajes de error
   return : ref cursor
   *************************************************************************/
   -- Bug 10093.NMM.05/11/2009. S'afegeixen 2 camps a la funció.
   -- Bug 27430 - 03/02/2014 - JTT: S'afegeixen els camps pnnumide, pbucar i pfcotiza a la funcio
   FUNCTION f_consultasimul(
      psproduc IN NUMBER,
      psolicit IN NUMBER,
      ptriesgo IN VARCHAR2,
      p_cramo IN NUMBER,
      p_filtroprod IN VARCHAR2,
      mensajes OUT t_iax_mensajes,
      pnnumide IN VARCHAR2 DEFAULT NULL,
      pbuscar IN VARCHAR2 DEFAULT NULL,
      pfcotiza IN DATE DEFAULT NULL,
      pnpoliza IN NUMBER DEFAULT NULL   -- Bug 34409/196980 20150420 POS
                                     )
      RETURN sys_refcursor;

   /*************************************************************************
   Recupera la solicitud guarda anteriormente
   param in psolicit : código simulación
   param out osproduc : código de producto
   param out mensajes : mensajes de error
   return : 0 todo ha sido correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_recuperasimul(
      psolicit IN NUMBER,
      osproduc OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/************************************************************************
 FI CONSULTA
************************************************************************/

   /************************************************************************
 INICI VALIDACIONS
************************************************************************/

   /*************************************************************************
   Valida datos de simulaciones
   param out mensajes : mensajes de error
   return : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_validaciones(ptipo VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/************************************************************************
 FI VALIDACIONS
************************************************************************/

   /*************************************************************************
   Devuelve la pregunta asegurado o tomador
   param out mensajes : mensajes de error
   return : VARCHAR2 la pregunta
   NULL ha habido error
   *************************************************************************/
   FUNCTION f_get_pregasgestom(preguntas OUT t_iax_mensajes, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
   Devuelve la pregunta asegurado o tomador
   param in respuesta : Respuesta a la pregunta 1 si, 0 no
   param in pcsituac : Situaci� p�lissa, si �s null es deixa la que te per defecte.
   param out mensajes : mensajes de error
   return : 0 Todo bien
   1 ha habido algun error
   *************************************************************************/
   FUNCTION f_emisionsimulacion(
      respuesta IN NUMBER,
      pcsituac IN NUMBER,   -- XPL#14/12/2010#BUG 16799: CRT003 - Alta rapida poliza correduria
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Recupera el asegurado del primer riesgo
   param out mensajes : mensajes de error
   return : OB_IAX_ASEGURADOS
   *************************************************************************/
   FUNCTION f_get_aseguradoprimerriesgo(mensajes OUT t_iax_mensajes)
      RETURN ob_iax_asegurados;

   -- Bug 9642 - 25/06/2009 - AMC
   /*************************************************************************
   Comprueba si la persona que viene de simulacion es ficticia
   param in psperson : código de la persona
   param in psproduc : código del producto
   param out pficti : indica si es ficticia
   param out mensajes : mensajes de error
   return : NUMBER
   *************************************************************************/
   FUNCTION f_actmodtom(
      psperson IN NUMBER,
      psproduc IN NUMBER,
      pficti OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-- Fi Bug 9642 - 25/06/2009 - AMC

   /*************************************************************************
   Graba el asegurado
   param in psperson : número de persona
   param in pcsexper : sexo de la persona
   param in pfnacimi : fecha nacimiento
   param in pnnumnif : número identificación persona
   param in tnombre : nombre de la persona
   param in tnombre1 : primer nombre de la persona
   param in tnombre2 : segundo nombre de la persona
   param in tapelli1 : primer apellido
   param in tapelli2 : segundo apellido
   param in pctipide : Tipo de identificación persona V.F. 672
   param in pctipper : Tipo de persona V.F. 85
   param out : mensajes de error
   return : 0 todo correcto
   1 ha habido un error

   Bug 25378/137309 - 18/02/2013 - AMC, Se a�ade los parametros pcpoblac,pcprovin,pcpais
   *************************************************************************/
   FUNCTION f_grabatomadores(
      psperson IN NUMBER,
      pcsexper IN NUMBER,
      pfnacimi IN DATE,
      pnnumnif IN VARCHAR2,
      ptnombre IN VARCHAR2,
      ptnombre1 IN VARCHAR2,
      ptnombre2 IN VARCHAR2,
      ptapelli1 IN VARCHAR2,
      ptapelli2 IN VARCHAR2,
      pctipide IN NUMBER,
      pctipper IN NUMBER,
      pcdomici IN NUMBER,
      pcpoblac IN NUMBER,
      pcprovin IN NUMBER,
      pcpais IN NUMBER,
      pcocupacion IN NUMBER,
      pcestciv IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_inserttomadores(
      psperson IN NUMBER,
      mensajes OUT t_iax_mensajes,
      ppregun OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   Elimina un tomador
   param in sperson : identificador del asegurado
   param out mensajes : mensajes de error
   return : 0 todo ha sido correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_eliminatomador(psperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_grababeneficiarios(
      pnriesgo IN NUMBER,
      psperson IN NUMBER,
      pcsexper IN NUMBER,
      pfnacimi IN DATE,
      pnnumnif IN VARCHAR2,
      ptnombre IN VARCHAR2,
      ptnombre1 IN VARCHAR2,
      ptnombre2 IN VARCHAR2,
      ptapelli1 IN VARCHAR2,
      ptapelli2 IN VARCHAR2,
      pctipide IN NUMBER,
      pctipper IN NUMBER,
      pnorden OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_grabaconductores(
      pnriesgo IN NUMBER,
      pnorden IN NUMBER,
      psperson IN NUMBER,
      pcsexper IN NUMBER,
      pfnacimi IN DATE,
      pnnumnif IN VARCHAR2,
      ptnombre IN VARCHAR2,
      ptnombre1 IN VARCHAR2,
      ptnombre2 IN VARCHAR2,
      ptapelli1 IN VARCHAR2,
      ptapelli2 IN VARCHAR2,
      pctipide IN NUMBER,
      pctipper IN NUMBER,
      pcprincipal IN NUMBER,
      pcdomici IN NUMBER,
      pcpais IN NUMBER,
      pcprovin IN NUMBER,
      pcpoblac IN NUMBER,
      pcocupacion IN NUMBER,
      pexper_manual IN NUMBER,   -- Bug 26907/148817 - 15/07/2013 - AMC
      pexper_cexper IN NUMBER,   -- Bug 26907/148817 - 15/07/2013 - AMC
      pexper_sinie IN NUMBER,
      pexper_sinie_manual IN NUMBER,
      pnpuntos IN NUMBER,   -- Bug 26907/148817 - 15/07/2013 - AMC
      pfcarnet IN DATE,   -- Bug 26907/148817 - 15/07/2013 - AMC
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_inicia_psu(
      p_tablas IN VARCHAR2,
      p_sseguro IN NUMBER,
      p_accion IN NUMBER,
      p_campo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Elimina un conductor
   param in sperson : identificador del asegurado
   param out mensajes : mensajes de error
   return : 0 todo ha sido correcto
   1 ha habido un error

   Bug 26907/147012 - 21/06/2013 - AMC
   *************************************************************************/
   FUNCTION f_eliminaconductor(psperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --Bug: 0027955/0152213 - JSV (05/09/2013)
   FUNCTION f_testtomadores(
      psperson IN NUMBER,
      pcsexper IN NUMBER,
      pfnacimi IN DATE,
      pnnumnif IN VARCHAR2,
      ptnombre IN VARCHAR2,
      ptnombre1 IN VARCHAR2,
      ptnombre2 IN VARCHAR2,
      ptapelli1 IN VARCHAR2,
      ptapelli2 IN VARCHAR2,
      pctipide IN NUMBER,
      pctipper IN NUMBER,
      pcdomici IN NUMBER,
      pcpoblac IN NUMBER,
      pcprovin IN NUMBER,
      pcpais IN NUMBER,
      pcocupacion IN NUMBER,
      pcestciv IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Bug27429 - 28/01/2014 -- JTT:
   /*************************************************************************
   Establece la simulacion como rechazada cambiando su situacion a 10 VF 61
   param in psseguro : cdigo de solicitud
   param in out mensajes : mensajes error
   return : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_rechazar_simul(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Recuperem la situacio de la simulacio
   param in psseguro : numero de simulacion
   param out ptsitsimul : estado de la simulacion
   param out pcsitsimul : codigo del estado de la simulacion
   param in out mensajes : mensajes error
   return : Situacion de la solicitud
   ************************************************************************/
   FUNCTION f_get_situacion_simul(
      psseguro IN NUMBER,
      ptsitsimul OUT VARCHAR2,
      pcsitsimul OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_iax_simulaciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIMULACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIMULACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIMULACIONES" TO "PROGRAMADORESCSI";
