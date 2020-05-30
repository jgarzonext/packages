--------------------------------------------------------
--  DDL for Package PAC_JOBS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_JOBS" AS
/******************************************************************************
   NOMBRE:       PAC_JOBS
   PROPÓSITO: Funciones para lanzar Oracle Jobs

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        12/03/2009   DCT                1. Creación del package.
******************************************************************************/

   --BUG7352 - 17/06/2009 - DCT - IAX - Desarrollo PL Cierres
   /*************************************************************************
      Registra un Job, retornando un SPROCES. Mas de todo para las trazas,
      se añade el usuario quien solicita al Job.
      param in pcusuari  : usuario quien solicita el SPROCES
      param out psproces : código del proceso
      param out          : mensajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   -- BUG 21546_108727- 23/02/2012 - JLTS - Se elimina el envío de mensajes
   FUNCTION f_registrar_job(pcusuari IN VARCHAR, psproces OUT NUMBER)
      RETURN NUMBER;

    --BUG7352 - 17/06/2009 - DCT - IAX - Desarrollo PL Cierres
   /*************************************************************************
      Lanza un job con el nombre tnombre y posibles parametros ptparams, separados por "|"'s
      param in psproces  : usuario quien solicita el SPROCES
      param in ptnombre  : nombre del job a ejecutar
      param in ptparams  : posibles parametros, separados por "|"'s, permite (NULL)
      param out          : mensajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   -- BUG 21546_108727- 23/02/2012 - JLTS - Se elimina el envío de mensajes
   FUNCTION f_ejecuta_job(psproces IN NUMBER, ptnombre IN VARCHAR, ptparams IN VARCHAR)
      RETURN NUMBER;

    --BUG7352 - 17/06/2009 - DCT - IAX - Desarrollo PL Cierres
   /*************************************************************************
      Retorna el estado de un proceso identificado como psproces.
      param in psproces  : usuario quien solicita el SPROCES
      param out pcstatus : estado del proceso
      param out          : mensajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   -- BUG 21546_108727- 23/02/2012 - JLTS - Se elimina el envío de mensajes
   FUNCTION f_status_job(psproces IN NUMBER, pcstatus OUT NUMBER)
      RETURN NUMBER;

-------------------------------------------------------------------
   FUNCTION f_inscolaproces(
      pcproces IN NUMBER,
      ptsentencia IN VARCHAR2,
      ppproces IN VARCHAR2,
      ptclave IN VARCHAR2)
      RETURN NUMBER;
END pac_jobs;

/

  GRANT EXECUTE ON "AXIS"."PAC_JOBS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_JOBS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_JOBS" TO "PROGRAMADORESCSI";
