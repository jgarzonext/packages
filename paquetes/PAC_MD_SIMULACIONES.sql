--------------------------------------------------------
--  DDL for Package PAC_MD_SIMULACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_SIMULACIONES" AS
   /******************************************************************************
   NOMBRE: AXIS_D37.PAC_MD_SIMULACIONES
   PROPÓSITO: Funciones para simulación en segunda capa

   REVISIONES:
   Ver Fecha Autor Descripción
   --------- ---------- -------- ------------------------------------
   1.0 19/12/2007 ACC 1. Creación del package.
   2.0 25/06/2009 AMC 3. Se añade la función f_actmodtom bug 9642
   3.0 05/11/2009 NMM 3. 10093: CRE - Afegir filtre per RAM en els cercadors.
   4.0 02/12/2011 AMC 4. Bug 20307/99655 - Se añaden nuevos parametros a la funcion f_grabaasegurado
   5.0 18/10/2012 XVM 5. 0023510: CALI102 - PPA i PIES - Corrección diverses
   6.0 05/09/2013 JSV 17. 0027955: LCOL_T031- QT GUI de Fase 3
   7.0 27/01/2014 JTT 7. 0027429: Persistencia simulaciones
   10.0 03/02/2014 JTT 10. 0027430: Añadir al filtro de busqueda de simulaciones el tomador y la fecha de cotizacion
   ******************************************************************************/

   /*************************************************************************
   Graba el asegurado como nueva persona
   param in psseguro : sseguro de la simulación
   param in pcsexper : sexo de la persona
   param in pfnacimi : fecha nacimiento
   param in pnnumnif : número identificación persona
   param in tnombre : nombre de la persona
   param in tnombre1 : primer nombre de la persona
   param in tnombre2 : segundo nombre de la persona
   param in tapelli1 : primer apellido
   param in tapelli2 : segundo apellido
   param in pcagente : código de agente
   param in osperson : número de persona
   param out : mensajes de error
   return : 0 todo correcto
   1 ha habido un error
   Bug 23510 - XVM - 18/10/2012 Se añade parámetro cagente
   *************************************************************************/
   FUNCTION f_grabaasegurados(
      psseguro IN NUMBER,
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
      pcagente IN NUMBER,
      osperson OUT NUMBER,
      pcocupacion IN NUMBER,
      pcestciv IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Establece la simulación como estudio cambiando su csituac a 7 VF 61
   param in psseguro : código de solicitud
   param in out mensajes : mensajes error
   return : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_simulestudi(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

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
      pnpoliza IN NUMBER,   -- Bug 34409/196980 - 16/04/2015 - POS
      ptriesgo IN VARCHAR2,
      p_cramo IN NUMBER,
      p_filtroprod IN VARCHAR2,
      pnnumide IN VARCHAR2 DEFAULT NULL,
      pbuscar IN VARCHAR2 DEFAULT NULL,
      pfcotiza IN DATE DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Devuelve el cestper de la persona
   param in psperson : código de la persona
   param out mensajes : mensajes de error
   return : NUMBER
   *************************************************************************/
   FUNCTION f_devuelvecestper(psperson IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Borra la persona
   param in psperson : código de la persona
   param out mensajes : mensajes de error
   return : NUMBER
   *************************************************************************/
   FUNCTION f_borrapersona(psperson IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

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

   --Bug: 0027955/0152213 - JSV (05/09/2013)
   FUNCTION f_test_estdireccion(pcpoblac IN NUMBER, pcprovin IN NUMBER)
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
   Grabar un registro en la tabla PERSISTENCIA_SIMUL si no existe
   param in psseguro : cdigo de solicitud
   param in out mensajes : mensajes error
   return : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_alta_persistencia_simul(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Actualiza el estado de la simulacion a 4 y borra la simulacion de la tabla de persisntecia
   param in psseguro : cdigo de solicitud
   param in out mensajes : mensajes error
   return : 0 todo correcto
   1 ha habido un error
   *************************************************************************/
   FUNCTION f_actualizar_persistencia(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   RRecuperem la situacio de la simulacio
   param in psseguro : numero de simulacion
   param out ptsitsimul : estado de la simulacion
   param out pcsitsimul : codigo del estado de la simulacion
   param in out mensajes : mensajes error
   return : Situacion de la solicitud
   ***********************************************************************/
   FUNCTION f_get_situacion_simul(
      psseguro IN NUMBER,
      ptsitsimul OUT VARCHAR2,
      pcsitsimul OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_simulaciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_SIMULACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SIMULACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SIMULACIONES" TO "PROGRAMADORESCSI";
