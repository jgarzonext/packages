--------------------------------------------------------
--  DDL for Package PAC_ALM_PROCESO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_ALM_PROCESO" AUTHID CURRENT_USER IS
/****************************************************************************
            NOMBRE:       PAC_ALM_PROCESO
            PROPÓSITO:  Funciones para cálculo provisiones CEM

            REVISIONES:
    Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------  ----------------------------------
    1.0        13/12/2010    JRH     16981: CEM - Proceso ALM  - Creación package.

****************************************************************************/-- BUG 0016981 - 12/2010 - JRH  -  Proceso ALM
   TYPE t_basestecnicas IS RECORD(
      vsseguro       seguros.sseguro%TYPE,
      vnriesgo       riesgos.nriesgo%TYPE,
      vcmodali       seguros.cmodali%TYPE,
      vccolect       seguros.ccolect%TYPE,
      vctipseg       seguros.ctipseg%TYPE,
      vcramo         seguros.cramo%TYPE,
      vfecproc       DATE,
      vnummes        NUMBER,
      vanualidad     NUMBER,
      vfechaprest    DATE,
      vefecpol       DATE,
      vsproduc       seguros.sproduc%TYPE,
      vnpoliza       seguros.npoliza%TYPE,
      vinteres_tec   NUMBER,
      vinteres_min   NUMBER,
      vinteres       NUMBER,
      vtablariesgo   NUMBER,
      vtablaahorro   NUMBER,
      vgee           NUMBER,
      vgii           NUMBER,
      vgprovext      NUMBER,
      vgprovint      NUMBER,
      vgadqui        NUMBER,
      vgrenta        NUMBER,
      vfecrevi       DATE,
      vfecrevi2      DATE,
      vfecvto        DATE,
      vfecvto2       DATE,
      vfnacimi1      DATE,
      vsexo1         per_personas.csexper%TYPE,
      vfnacimi2      DATE,
      vsexo2         per_personas.csexper%TYPE,
      vpcapfall      seguros_ren.pcapfall%TYPE,
      vpdoscab       seguros_ren.pdoscab%TYPE,
      vicapren       NUMBER,
      vfrevant       DATE,
      vsobremort     NUMBER,
      vcrevali       NUMBER,
      virevali       NUMBER,
      vprevali       NUMBER,
      vanyosmenos    NUMBER,
      vctipefe       NUMBER,
      vnrenova       NUMBER,
      vanyostot      NUMBER,
      vesvitalicia   BOOLEAN,
      vinteres_gast_tec NUMBER(14, 8),
      vinteres_gast_min NUMBER(14, 8),
      vinteres_gast  NUMBER(14, 8),
      vinteres_mens_tec NUMBER(14, 8),
      vinteres_mens_min NUMBER(14, 8),
      vinteres_mens  NUMBER(14, 8),
      vcclaren       NUMBER,
      vctipren       NUMBER,
      vedadlimite    NUMBER,
      vlimitegenerico NUMBER,
      vlimitesalud   NUMBER,
      vlimiteedad    NUMBER,
      valmaxcapirisc NUMBER,
      vporccapital   NUMBER,
      vcapitalriesgo NUMBER,
      vaportacion    NUMBER,
      vesrenta       BOOLEAN,
      vesrentairreg  BOOLEAN,
      vpagasextra    VARCHAR2(30),
      vrenta         NUMBER,
      vforpagren     NUMBER,
      vcforpag       NUMBER,
      vfcaranu       DATE,
      vfprimrent     DATE,
      vfproxrent     DATE,
      vedeadini1     NUMBER,
      vedeadini2     NUMBER,
      vndurper       NUMBER,
      vprogresionprima NUMBER,
      vprogresionrenta NUMBER,
      vtiemp         NUMBER,
      vtiempmax      NUMBER,
      vtiempmin      NUMBER,
      vpagarenta     NUMBER,
      vpagaprima     NUMBER,
      vrentamin      NUMBER,
      vultsaldo      NUMBER,
      vultcapgar     NUMBER,
      vultcapfall    NUMBER,
      vultfecha      DATE,
      vnnumlin       NUMBER,
      vrentamaxfija  NUMBER,
      vrentaminfija  NUMBER,
      vaportacionfija NUMBER,
      vaportacioninifija NUMBER,
      vrentainifija  NUMBER,
      vprovfecrevi   NUMBER,
      vfecfinal      DATE,
      vanyosfinal    NUMBER,
      vinteresdia    NUMBER,
      vinteremindia  NUMBER,
      vfecprocreal   DATE,
      vconmu         t_conmutador,
      vconmur        t_conmutador
   );

   --pbasestecnicas t_basestecnicas; --Lo ponemos aquí por rendimiento, si se pasa como parámetro a una función
                                    --tarda mucho. Se supone que un object type también

   /*************************************************************************
      f_generar_alm_poliza
      Genera alm de una póliza
      param in   psproces : Número de proceso
      param in   pfproces : Fecha del proceso
      param in  psseguro : Sseguro
      Retorna diferente de 0 (un código de error) en caso de error
   *************************************************************************/
   FUNCTION f_generar_alm_poliza(
      psproces IN NUMBER,
      pfproces IN DATE,
      psseguro IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER;

/*************************************************************************
      f_generar_alm
      Genera alm de una póliza
      param in   psproces : Número de proceso
      param in   pfproces : Fecha del proceso
      param in   pcramo : Ramo
      param in   psproduc : Producto
      param in  psseguro : Sseguro
      Retorna diferente de 0 (un código de error) en caso de error
   *************************************************************************/
   FUNCTION f_generar_alm(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pfproces IN DATE,
      pcagrup IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER;

-- Fi BUG 0016981 - 12/2010 - JRH

   /************************************************************************
       f_proceso_cierre
          Proceso batch de inserción de la ALM en CTASEGURO

        Parámetros Entrada:

            psmodo : Modo (1-->Previo y '2 --> Real)
            pcempres: Empresa
            pmoneda: Divisa
            pcidioma: Idioma
            pfperini: Fecha Inicio
            pfperfin: Fecha Fin
            pfcierre: Fecha Cierre

        Parámetros Salida:

            pcerror : <>0 si ha habido algún error
            psproces : Proceso
            pfproces : Fecha en que se realiza el proceso

    *************************************************************************/
   PROCEDURE p_proceso_cierre(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      pcagrup IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE);

    /************************************************************************
      proceso_batch_cierre
         Proceso batch de inserción de la PB en CTASEGURO

       Parámetros Entrada:

           psmodo : Modo (1-->Previo y '2 --> Real)
           pcempres: Empresa
           pmoneda: Divisa
           pcidioma: Idioma
           pfperini: Fecha Inicio
           pfperfin: Fecha Fin
           pfcierre: Fecha Cierre

       Parámetros Salida:

           pcerror : <>0 si ha habido algún error
           psproces : Proceso
           pfproces : Fecha en que se realiza el proceso

   *************************************************************************/
   PROCEDURE proceso_batch_cierre(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE);
END pac_alm_proceso;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_ALM_PROCESO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_ALM_PROCESO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_ALM_PROCESO" TO "PROGRAMADORESCSI";
