--------------------------------------------------------
--  DDL for Package PAC_IAX_GESTION_PROCESOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_GESTION_PROCESOS" 
AS
/******************************************************************************
   NOMBRE:      pac_iax_gestion_procesos
   PROPÓSITO: Funciones para la gestión de la carga de procesos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        10/05/2010   XPL              1. Creación del package.
   2.0        06/07/2010   PFA              2. 14750: ENSA101 - Reproceso de procesos ya existentes
   3.0        11/10/2010   FAL              3. 0014888: CRT002 - Carga de polizas,recibos y siniestros Allianz
   4.0        26/10/2010   FAL              4. 0016324: CRT002 - Configuracion de las cargas
   5.0        18/01/2011   ICV              5. 0017155: CRT003 - Informar estado actualizacion compañia
   6.0        26/07/2013   JRH              6  0024736 - 26/07/2013- JRH - 0024736: (POSDE600)-Desarrollo-GAPS Tecnico-Id 25 - Cotizaciones Masivas CP (Carga Fichero)
   7.0        21/12/2015   YDA              7. 0038922: Se crea la función f_get_tabla_intermedia_text
******************************************************************************/

   /*************************************************************************
      función que graba en la cabecera del control de procesos
       param in psproces  : Num procesos de la carga
       param in ptfichero : Nombre fichero a cargar
       param in pfini     : Fecha inicio carga
       param in pffin     : Fecha fin carga
       param in pcestado  : Estado de la carga
       param in pcproceso : Codigo proceso
       param in pcerror   : Error de la carga (Slitera)
       param out          : mensajes de error
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_carga_ctrl_cabecera(
      psproces    IN       NUMBER,
      ptfichero   IN       VARCHAR2,
      pfini       IN       DATE,
      pffin       IN       DATE,
      pcestado    IN       NUMBER,
      pcproceso   IN       NUMBER,
      pcerror     IN       NUMBER,
      pterror     IN       VARCHAR2,
      pcbloqueo   IN       NUMBER,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER;

/*************************************************************************
      función que graba en la linea que se esta tratando del fichero a cargar
       param in psproces  : Num procesos de la carga
       param in pnlinea   : Num Linea
       param in pctipo    : Tipo de registro (Poliza, Siniestro, Recibo, Persona)
       param in pidint    : Identificador interno visual
       param in pidext    : Identificador externo
       param in pcestado  : Estado de la linea
       param in pcvalidado: Linea validada
       param in psseguro  : Codigo del seguro en el caso que carguemos un seguro
       param in pnsinies  : Codigo del siniestros en el caso que carguemos un siniestro
       param in pntramit  : Codigo de la tramitación en el caso que carguemos un siniestro
       param in psperson  : Codigo de la persona en el caso que carguemos una persona
       param in pnrecibo  : Codigo del recibo en el caso que carguemos un recibo
       param out          : mensajes de error
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_carga_ctrl_linea(
      psproces     IN       NUMBER,
      pnlinea      IN       NUMBER,
      pctipo       IN       NUMBER,
      pidint       IN       VARCHAR2,
      pidext       IN       VARCHAR2,
      pcestado     IN       NUMBER,
      pcvalidado   IN       NUMBER,
      psseguro     IN       NUMBER,
      -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
      pidexterno   IN       VARCHAR2,
      -- Fi Bug 14888
      -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
      pncarga      IN       NUMBER,
      -- Fi Bug 16324
      pnsinies     IN       VARCHAR2,
      pntramit     IN       NUMBER,
      psperson     IN       NUMBER,
      pnrecibo     IN       NUMBER,
      mensajes     OUT      t_iax_mensajes
   )
      RETURN NUMBER;

/*************************************************************************
       función que graba el error de la linea del fichero que se esta cargando
       param in psproces  : Num procesos de la carga
       param in pnlinea   : Num Linea
       param in pnerror   : Num Error
       param in pctipo    : Tipo de error(warning, error, informativo)
       param in pcerror   : Codigo de error
       param in ptmensaje : Mensaje a mostrar
       param out          : mensajes de error
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_carga_ctrl_linea_error(
      psproces    IN       NUMBER,
      pnlinea     IN       NUMBER,
      pnerror     IN       NUMBER,
      pctipo      IN       NUMBER,              --warning, error, informativo
      pcerror     IN       NUMBER,
      ptmensaje   IN       VARCHAR2,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER;

   /*************************************************************************
      función que recupera los registros de la cabecera de carga.
       param in psproces  : Num procesos de la carga
       param in ptfichero : Nombre fichero a cargar
       param in pfini     : Fecha inicio carga
       param in pffin     : Fecha fin carga
       param in pcestado  : Estado de la carga
       param in pcerror   : Error de la carga (Slitera)
       param out          : mensajes de error
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_get_carga_ctrl_cabecera(
      psproces    IN       NUMBER,
      ptfichero   IN       VARCHAR2,
      pfini       IN       DATE,
      pffin       IN       DATE,
      pcestado    IN       NUMBER,
      pcproceso   IN       NUMBER,                 -- BUG16432:JBN:29/10/2010
      pcrefext    IN       VARCHAR2,
      pcurcarga   OUT      sys_refcursor,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER;

   /*************************************************************************
      función que recupera los registros de la linea del proceso cargado
       param in psproces  : Num procesos de la carga
       param in pnlinea   : Num Linea
       param in pctipo    : Tipo de carga(Siniestros,polizas, personas, recibos...)
       param in pvalor    : Valor segun tipo de carga(siniestros = nsinies, polizas = sseguro...)
       param in pidint    : Identificador interno
       param in pidext    : Identificador externo
       param in pcestado  : Estado de la linea (si ha sido informado) o de la carga
       param in pcrevisado : Linea revisada o no
       param out          : mensajes de error
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_get_carga_ctrl_linea(
      psproces         IN       NUMBER,
      pnlinea          IN       NUMBER,
      pctipo           IN       NUMBER,
      pvalor           IN       VARCHAR2,
      pidint           IN       VARCHAR2,
      pidext           IN       VARCHAR2,
      pcestado         IN       NUMBER,
      pcrevisado       IN       NUMBER,
      pcurcargalinea   OUT      sys_refcursor,
      mensajes         OUT      t_iax_mensajes
   )
      RETURN NUMBER;

   /*************************************************************************
       función que recupera los registros de los errores de la linea del proceso cargado
       param in psproces  : Num procesos de la carga
       param in pnlinea   : Num Linea
       param in pnerror   : Num Error
       param out          : mensajes de error
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_get_carga_ctrl_linea_error(
      psproces              IN       NUMBER,
      pnlinea               IN       NUMBER,
      pnerror               IN       NUMBER,
      pcurcargalinea_errs   OUT      sys_refcursor,
      mensajes              OUT      t_iax_mensajes
   )
      RETURN NUMBER;

--Bug 14750-PFA-06/07/2010
   /*************************************************************************
      función que recupera los registros de la tabla intermedia correspondiente
       param in psproces  : Num proceso de la carga
       param in pcproceso : Identificador del proceso
       param in pnlinea   : Num Linea
       param out pobtablaproceso   : Informacion de la tabla
       param out          : mensajes de error
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_get_tabla_intermedia(
      psproces          IN       NUMBER,
      pcproceso         IN       NUMBER,
      pnlinea           IN       NUMBER,
      pobtablaproceso   OUT      ob_iax_tabla_procesos,
      mensajes          OUT      t_iax_mensajes
   )
      RETURN NUMBER;

   FUNCTION f_get_tabla_intermedia_text(
      psproces    IN       NUMBER,
      pcproceso   IN       NUMBER,
      pnlinea     IN       NUMBER,
      ptexto      OUT      VARCHAR2,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER;

   /*************************************************************************
      función que modifica los registros de la tabla intermedia correspondiente
       param in psproces  : Num proceso de la carga
       param in pcproceso : Identificador del proceso
       param in pnlinea   : Num Linea
       param in pcolumna  : Columna a modificar
       param in pvalor    : Valor modificado
       param out          : mensajes de error
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_tabla_intermedia(
      psproces    IN       NUMBER,
      pcproceso   IN       NUMBER,
      pnlinea     IN       NUMBER,
      pcolumna    IN       VARCHAR2,
      pvalor      IN       VARCHAR2,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER;

--Fi Bug 14750-PFA-06/07/2010
   -- Bug 16432-JBN-09/11/2010
   /*************************************************************************
         función que modifica el estado de una linea
       param in psproces  : Num proceso de la carga
       param in pcestado :  Nuevo estado a modificar
       param in pnlinea   : Num Linea
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_cestado_lineaproceso(
      psproces   IN       NUMBER,
      pnlinea    IN       NUMBER,
      pcestado   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER;

--Fi Bug 16432-JBN-09/11/2010

   --Bug.: 0017155 - 18/01/2011 - ICV
/*************************************************************************
       función que devuelve un sys_refcursor con el último fichero cargado de la compañia de la póliza/siniestro/recibo
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_get_carga_fichero(
      pctipo      IN       NUMBER,
      pccompani   IN       NUMBER,
      psseguro    IN       NUMBER,
      pnsinies    IN       VARCHAR2,
      pnrecibo    IN       NUMBER,
      pcurcarga   OUT      sys_refcursor,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER;

--Fi Bug 0017155

   --Bug 24736 - 26/07/2013- JRH - 0024736: (POSDE600)-Desarrollo-GAPS Tecnico-Id 25 - Cotizaciones Masivas CP (Carga Fichero)
/*************************************************************************
       función que devuelve un sys_refcursor con los ficheros de salida asociados
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_get_ficheros(
      pcempres    IN       NUMBER,
      psproces    IN       NUMBER,
      pcproceso   IN       NUMBER,
      vtimp       OUT      t_iax_impresion,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER;
--Fi Bug 24736 - 26/07/2013- JRH
END pac_iax_gestion_procesos;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_GESTION_PROCESOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_GESTION_PROCESOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_GESTION_PROCESOS" TO "PROGRAMADORESCSI";
