--------------------------------------------------------
--  DDL for Package PAC_GESTION_PROCESOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_GESTION_PROCESOS" AS
/******************************************************************************
   NOMBRE:      pac_gestion_procesos
   PROP¿SITO: Funciones para la gesti¿n de la carga de procesos

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        10/05/2010   XPL              1. Creaci¿n del package.
   2.0        06/07/2010   PFA              2. 14750: ENSA101 - Reproceso de procesos ya existentes
   3.0        11/10/2010   FAL              3. 0014888: CRT002 - Carga de polizas,recibos y siniestros Allianz
   4.0        26/10/2010   FAL              4. 0016324: CRT002 - Configuracion de las cargas
   5.0        09/11/2010   JBN              5. 0016432: CRT002 - Error en axisint001 - Volumen elevado de registros
   6.0        18/01/2011   ICV              6. 0017155: CRT003 - Informar estado actualizacion compa¿ia
******************************************************************************/

   /*************************************************************************
      funci¿n que graba en la cabecera del control de procesos
       param in psproces  : Num procesos de la carga
       param in ptfichero : Nombre fichero a cargar
       param in pfini     : Fecha inicio carga
       param in pffin     : Fecha fin carga
       param in pcestado  : Estado de la carga
       param in pcproceso : Codigo proceso
       param in pcerror   : Error de la carga (Slitera)
       param in pcbloqueo : Indica si el proceso esta bloqueado para reproceso
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_carga_ctrl_cabecera(
      psproces IN NUMBER,
      ptfichero IN VARCHAR2,
      pfini IN DATE,
      pffin IN DATE,
      pcestado IN NUMBER,
      pcproceso IN NUMBER,
      pcerror IN NUMBER,
      pterror IN VARCHAR2,
      pcbloqueo In NUMBER default 0 )
      RETURN NUMBER;

/*************************************************************************
      funci¿n que graba en la linea que se esta tratando del fichero a cargar
       param in psproces  : Num procesos de la carga
       param in pnlinea   : Num Linea
       param in pctipo    : Tipo de registro (Poliza, Siniestro, Recibo, Persona)
       param in pidint    : Identificador interno visual
       param in pidext    : Identificador externo
       param in pcestado  : Estado de la linea
       param in pcvalidado: Linea validada
       param in psseguro  : Codigo del seguro en el caso que carguemos un seguro
       param in pnsinies  : Codigo del siniestros en el caso que carguemos un siniestro
       param in pntramit  : Codigo de la tramitaci¿n en el caso que carguemos un siniestro
       param in psperson  : Codigo de la persona en el caso que carguemos una persona
       param in pnrecibo  : Codigo del recibo en el caso que carguemos un recibo
       param in out       : mensajes de error
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_carga_ctrl_linea(
      psproces IN NUMBER,
      pnlinea IN NUMBER,
      pctipo IN NUMBER,
      pidint IN VARCHAR2,
      pidext IN VARCHAR2,
      pcestado IN NUMBER,
      pcvalidado IN NUMBER,
      psseguro IN NUMBER,
      -- Bug 14888. FAL. 11/10/2010. A¿adir id. externo (npoliza,nsinies,nrecibo) de la compa¿ia
      pidexterno IN VARCHAR2,
      -- Fi Bug 14888
      -- Bug 16324. FAL. 26/10/2010. A¿adir ncarga (relacion con tablas mig)
      pncarga IN NUMBER,
      -- Fi Bug 16324
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      psperson IN NUMBER,
      pnrecibo IN NUMBER)
      RETURN NUMBER;

/*************************************************************************
       funci¿n que graba el error de la linea del fichero que se esta cargando
       param in psproces  : Num procesos de la carga
       param in pnlinea   : Num Linea
       param in pnerror   : Num Error
       param in pctipo    : Tipo de error(warning, error, informativo)
       param in pcerror   : Codigo de error
       param in ptmensaje : Mensaje a mostrar
       param in in out    : mensajes de error
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_carga_ctrl_linea_error(
      psproces IN NUMBER,
      pnlinea IN NUMBER,
      pnerror IN NUMBER,
      pctipo IN NUMBER,   --warning, error, informativo
      pcerror IN NUMBER,
      ptmensaje IN VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      funci¿n que recupera los registros de la cabecera de carga.
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
      psproces IN NUMBER,
      ptfichero IN VARCHAR2,
      pfini IN DATE,
      pffin IN DATE,
      pcestado IN NUMBER,
      pcprocesos IN NUMBER,   -- BUG16432:JBN:29/10/2010
      pcempres IN NUMBER,   -- BUG16432:JBN:29/10/2010
      pcidioma IN NUMBER,
      pcrefext IN VARCHAR2,   -- BUG17045:LCF:12/01/2011
      psquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      funci¿n que recupera los registros de la linea del proceso cargado
       param in psproces  : Num procesos de la carga
       param in pnlinea   : Num Linea
       param out          : mensajes de error
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_get_carga_ctrl_linea(
      psproces IN NUMBER,
      pnlinea IN NUMBER,
      pcidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
       funci¿n que recupera los registros de los errores de la linea del proceso cargado
       param in psproces  : Num procesos de la carga
       param in pnlinea   : Num Linea
       param in pnerror   : Num Error
       param out          : mensajes de error
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_get_carga_ctrl_linea_error(
      psproces IN NUMBER,
      pnlinea IN NUMBER,
      pnerror IN NUMBER,
      pcidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
      funci¿n que recupera los registros de la linea del proceso cargado
       param in psproces  : Num procesos de la carga
       param in pnlinea   : Num Linea
       param in pctipo    : Tipo de carga(Siniestros,polizas, personas, recibos...)
       param in pfini     : Fecha de inicio
       param in pffin     : Fecha de fin
       param in pvalor    : Valor segun tipo de carga(siniestros = nsinies, polizas = sseguro...)
       param in pidint    : Identificador interno
       param in pidext    : Identificador externo
       param in pcestado  : Estado de la linea
       param in pcrevisado : Linea revisada o no
       param out          : mensajes de error
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_get_carga_ctrl_linea(
      psproces IN NUMBER,
      pnlinea IN NUMBER,
      pctipo IN NUMBER,
      pfini IN DATE,
      pffin IN DATE,
      pvalor IN VARCHAR2,
      pidint IN VARCHAR2,
      pidext IN VARCHAR2,
      pcestado IN NUMBER,
      pcrevisado IN NUMBER,
      pcidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER;

--Bug 14750-PFA-06/07/2010
/*************************************************************************
      funci¿n que recupera los registros de la tabla intermedia correspondiente
       param in psproces  : Num proceso de la carga
       param in pcproceso : Identificador del proceso
       param in pnlinea   : Num Linea
       param out vtabla   : Informacion de la tabla
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_get_tabla_intermedia(
      psproces IN NUMBER,
      pcproceso IN NUMBER,
      pnlinea IN NUMBER,
      pcempres IN NUMBER,
      vtabla OUT VARCHAR2)
      RETURN NUMBER;

--Fi Bug 14750-PFA-06/07/2010

   -- Bug 16432-JBN-09/11/2010
   /*************************************************************************
         funci¿n que modifica el estado de una linea
       param in psproces  : Num proceso de la carga
       param in pcestado :  Nuevo estado a modificar
       param in pnlinea   : Num Linea
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_cestado_lineaproceso(
      psproces IN NUMBER,
      pnlinea IN NUMBER,
      pcestado IN NUMBER)
      RETURN NUMBER;

--Fi Bug 16432-JBN-09/11/2010

   --Bug.: 0017155 - 18/01/2011 - ICV
   /*************************************************************************
       funci¿n que insert el fichero de carga una vez procesado y ok
       param in ccompani  : C¿digo Compa¿¿a
       param in tfichero :  Nombre del fichero
       param in ctipo   : Tipo de fichero
       param in fcarga   : Fecha de carga
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_carga_fichero(
      pccompani IN NUMBER,
      ptfichero IN VARCHAR2,
      pctipo IN NUMBER,
      pfcarga IN DATE)
      RETURN NUMBER;

   /*************************************************************************
         funci¿n que devuelve un sys_refcursor con el ¿ltimo fichero cargado de la compa¿ia de la p¿liza/siniestro/recibo
         return             : 0 todo ha sido correcto
                              1 ha habido un error
     *************************************************************************/
   FUNCTION f_get_carga_fichero(
      pctipo IN NUMBER,
      pccompani IN NUMBER,
      psseguro IN NUMBER,
      pnsinies IN VARCHAR2,
      pnrecibo IN NUMBER,
      pcidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER;

--Fi Bug 0017155

   /*************************************************************************
         funci¿n que devuelve el resumen de la carga
         param in psproces  : C¿digo del proceso
         param in pcidioma :  C¿digo del Idioma
         return             : Texto del resumen

         Bug 26050/142735 - 18/04/2013 - AMC
   *************************************************************************/
   FUNCTION f_get_resumen_carga(psproces IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;
END pac_gestion_procesos;

/

  GRANT EXECUTE ON "AXIS"."PAC_GESTION_PROCESOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_GESTION_PROCESOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_GESTION_PROCESOS" TO "PROGRAMADORESCSI";
