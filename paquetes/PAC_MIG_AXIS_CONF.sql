CREATE OR REPLACE PACKAGE pac_mig_axis_conf IS
   /***************************************************************************
      NOMBRE:       pac_mig_axis_conf
      PROPÃ“SITO:    Proceso de traspaso de informacion de las tablas MIG_ a las
                    distintas tablas de AXIS
      REVISIONES:
      Ver        Fecha       Autor       DescripciÃ³n
      ---------  ----------  ----------  --------------------------------------
      1.0        22-10-2008  JMC         CreaciÃ³n del package
      2.0        02-06-2009  JMC         Se aÃ±aden y modifican funciones para la
                                         migraciÃ³n de DETMOVSEGURO, DETGARANSEG
                                         y MOVRECIBO. (bug 8402)
      3.0        12-06-2009  JMC         Se aÃ±ade funciÃ³n para la migraciÃ³n de la
                                         tabla MIG_COMISIGARANSEG.
                                         Se aÃ±aden mejoras en el proceso de
                                         borrado de las cargas. (bug 10395)
      4.0        30-09-2009  JMC         Se aÃ±aden procesos para la carga de las
                                         tablas SEGUROS_ULK y TABVALCES.(bug 11115)
      5.0        22-10-2009  JMC         Se aÃ±ade funciÃ³n f_mig_parpersonas (bug 10054)
      6.0        05-11-2009  JMF         bug 0011578 Incorporar proceso post-migraciÃ³n
                                         para la creaciÃ³n del Ãºltimo movimiento de CESIONESREA
      7.0        02-12-2009  JMC         Bug 0012243: AÃ±adir identificador de las cargas de las migraciones.
      8.0        21-12-2009  JMC         Bug 0012374: MigraciÃ³n tabla PRESTAMOSEG.
                                                      MigraciÃ³n nuevo modelo siniestros.
                                                      AÃ±adir parÃ¡metro sproduc en p_post_instalacion_rea y
                                                      p_migra_cesiones.
      9.0        14-01-2010  JMC         Bug 0012557: Ajustes proceso migraciÃ³n, para arreglar incidencias
                                                      detectadas migraciÃ³n validaciÃ³n 30/12/2009.
                                                      Se aÃ±aden las funciones :
                                                      f_migra_sup_diferidosseg
                                                      f_migra_sup_acciones_dif
                                                      f_migra_pagosrenta
     10.0        15-01-2010  ICV         Bug 0011364: CEM - Traspasos - Carga Tablas
     11.0        11-05-2010  JMC         Bug 0014185: Se elimina las funciones del modelo antiguo de SINIESTROS.
     12.0        28-09-2010  AFM         Bug 0014954: CRE998 - MigraciÃ³n mÃ³dulo siniestros de OLDAXIS a NEWAXIS (se aÃ±aden
                                                      las funciones  f_migra_sin_tramita_agenda y f_migra_sin_tramita_destinatario)
                                                                           JMC-Bug 0015640: Se aÃ±ade funciÃ³n f_migra_direcciones para la migraciÃ³n de la
                                                      tabla mig_direcciones en caso que la/s direccion/es no se
                                                      encuentren en mig_personas.
     13.0        31-01-2011  JMF         Bug 0017015 CCAT702 - MigraciÃ³ i parametritzaciÃ³ de les dades referents a processos
     14.0        26-04-2011  JMC         Bug 0018334 LCOL702 - Carga pÃ³lizas.
     15.0        07-11-2011  JMC         Bug 0020003: LCOL001-AdaptaciÃ³ migraciÃ³ persones
     16.0        22-02-2012  APD         Bug 0021121: MDP701 - TEC - DETALLE DE PRIMAS DE GARANTIAS
     17.0        25/05/2012  JMC         Bug 0022393: MdP - MIG - Viabilidad tarificaciÃ³n productos de migraciÃ³n de Hogar
     18.0        17/09/2013  SCO         Add FunciÃ³n de migraciÃ³n
     19.0        17/10/2013  SCO         Add FunciÃ³n de migraciÃ³n
     20.0        22/10/2015  ETM         Bug 34776/216124: MSV0007-MigraciÃ³n MSV/ aÃ±adir las tablas MIG_CTASEGURO_SHADOW Y MIG_SEGDISIN2
     21.0        26/07/2017  HAG         Nuevas funciones para migraciÃ³n CONF
   ***************************************************************************/
   g_cestado      VARCHAR2(10);
   cresmig_pk     MIG_SIN_TRAMITA_RESERVA.MIG_PK%TYPE;--VARIABLE PARA RESERVADET
   cusualtres     MIG_SIN_TRAMITA_RESERVA.CUSUALT%TYPE;--VARIABLE PARA RESERVADET 7782-22
   /***************************************************************************
                        FUNCTION f_codigo_axis
      Dado un valor de un cÃ³digo de la empresa, nos devuelve el valor del
      cÃ³digo en AXIS
         param in  pcempres:  CÃ³digo empresa
         param in  pccodigo:  CÃ³digo a convertir
         param in  pcvalemp:  Valor en empresa del cÃ³digo
         param out pcvalaxis: Valor en AXIS del cÃ³digo
         return:              CÃ³digo error
   ***************************************************************************/
   FUNCTION f_codigo_axis(
      pcempres IN VARCHAR2,
      pccodigo IN VARCHAR2,
      pcvalemp IN VARCHAR2,
      pcvalaxis OUT VARCHAR2)
      RETURN NUMBER;

   /***************************************************************************
      FUNCTION f_ins_mig_logs_axis
      FunciÃ³n para insertar registros en la tabla de Errores y Warnings del
      proceso de migraciÃ³n entre las tablas MIG y AXIS
         param in  pncarga:  NÃºmero de carga
         param in  pmig_pk:  valor primary key de la tabla MIG
         param in  ptipo:    Tipo Traza (E-Error,W-Warning,I-Informativo)
         param in  ptexto:   Texto de la traza
         return:             CÃ³digo error
   ***************************************************************************/
   FUNCTION f_ins_mig_logs_axis(
      pncarga IN NUMBER,
      pmig_pk IN VARCHAR2,
      ptipo IN VARCHAR2,
      ptexto IN VARCHAR2)
      RETURN NUMBER;

/***************************************************************************
      FUNCTION f_act_hisseg
      FunciÃ³n que inserta en la tabla historicoseguros con la
      informaciÃ³n previa a una modificaciÃ³n de la tabla seguros.
         param in  pmig_fk2:     Identificador de la PK de la tabla MIG_MOVSEGURO.
         param in  psseguro:     Identificador de la pÃ³liza.
         param in  pnmovimi:     NÃºmero de movimiento de la pÃ³liza.
         param in  ptablas:      EST, POL por defecto es POL   -- 23289/120321 - ECP - 03/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_act_hisseg(
      pncarga  IN NUMBER,
      pmig_fk2 IN VARCHAR2,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
      
   /***************************************************************************
             FUNCTION f_lanza_post
       FunciÃ³n que realiza las acciones post definidas en la tabla MIG_POST
          param in ptabla:    Tablas origen 'EST', 'POL'.
          param in out psseguro:  Seguro de las tablas origen. Salida, sseguro en la tabla definitiva
          param in psproduc:  Producto de la poliza
          param in pfefecto:  Fecha de efecto del movimiento
          param in pnmovimi   Numero de movimiento
          param out pmens
          return:                0-OK, <>0-Error
    ***************************************************************************/
   FUNCTION f_lanza_post(
      pncarga IN NUMBER,
      ptabla IN VARCHAR2,
      psseguro IN OUT seguros.sseguro%TYPE,
      psproduc productos.sproduc%TYPE,
      pfefecto DATE,
      pnmovimi IN NUMBER,
      pmens IN OUT VARCHAR2,
      pmodo IN VARCHAR2 DEFAULT 'GENERAL',
      pcactivi IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   --   FUNCTION f_migra_carga(pncarga IN NUMBER, pntab IN NUMBER)
   --      RETURN NUMBER;
   /***************************************************************************
                        FUNCTION f_migra_personas
      FunciÃ³n que inserta los registros grabados en MIG_PERSONAS, en las distintas
      tablas de personas de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_personas(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   -- BUG 10054 - 22-10-2009 - JMC - FunciÃ³n para la migraciÃ³n de la tabla PER_PARPERSONAS
   /***************************************************************************
                        FUNCTION f_migra_parpersonas
      FunciÃ³n que inserta los registros grabados en MIG_PARPERSONAS, en la
      tabla de parametros de personas de AXIS. (PER_PARPERSONAS)
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_parpersonas(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
   /***************************************************************************
      FUNCTION f_migra_per_agr_marcas
      FunciÃ³n que inserta los registros grabados en MIG_PER_AGR_MARCAS, en la
      tabla de parametros de personas de AXIS. (PER_AGR_MARCAS)
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_per_agr_marcas(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
   -- FIN BUG 10054 - 22-10-2009 - JMC
   /***************************************************************************
                        FUNCTION f_migra_agentes
      FunciÃ³n que inserta las personas grabadas en MIG_AGENTES, en las distintas
      tablas de agentes de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_agentes(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
   /***************************************************************************
      FUNCTION f_migra_bureau
      FunciÃ³n que inserta los registros grabados en MIG_BUREAU, en la tabla
      BUREAU de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas  -- 23289/120321 - ECP- 04/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_bureau(pncarga IN NUMBER, pntab IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
   /***************************************************************************
                        FUNCTION f_migra_seguros
      FunciÃ³n que inserta las pÃ³lizas grabadas en MIG_SEGUROS, en las distintas
      tablas de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_seguros(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                        FUNCTION f_migra_seguros_ren_aho
      FunciÃ³n que inserta los registros grabados en MIG_SEGUROSREN_AHO, en las
      tablas SEGUROS_REN y SEGUROS_AHO de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_seguros_ren_aho(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                        FUNCTION f_migra_asegurados
      FunciÃ³n que inserta los registros grabados en MIG_ASEGURADOS, en la tabla
      ASEGURADOS de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_asegurados(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                        FUNCTION f_migra_riesgos
      FunciÃ³n que inserta los registros grabados en MIG_RIESGOS, en la tabla
      RIESGOS de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_riesgos(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   -- BUG 0018334 - 26-04-2011 - JMC - Carga pÃ³lizas
   /***************************************************************************
                        FUNCTION f_migra_autriesgos
      FunciÃ³n que inserta los registros grabados en MIG_AUTRIESGOS, en la tabla
      AUTRIESGOS de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas  -- 23289/120321 - ECP- 03/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_autriesgos(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                        FUNCTION f_migra_autdetriesgos
      FunciÃ³n que inserta los registros grabados en MIG_AUTDETRIESGOS, en la tabla
      AUTDETRIESGOS de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas  -- 23289/120321 - ECP- 03/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_autdetriesgos(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
        FUNCTION f_migra_autdisriesgos
        FunciÃ³n que inserta los registros grabados en MIG_AUTDISRIESGOS, en la tabla
        AUTDETRIESGOS de AXIS.
           param in  pncarga:     NÃºmero de carga.
           param in  pntab:       NÃºmero de tabla.
           param in  ptablas      EST Simulaciones POL PÃ³lizas  -- 23289/120321 - ECP- 03/09/2012
           return:                0-OK, <>0-Error
     ***************************************************************************/
   FUNCTION f_migra_autdisriesgos(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

/***************************************************************************
      FUNCTION f_migra_autconductores
      FunciÃ³n que inserta los registros grabados en MIG_AUTCONDUCTORES, en la tabla
      AUTCONDUCTORES de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas  -- 23289/120321 - ECP- 03/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_autconductores(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

/***************************************************************************
      FUNCTION f_migra_bonfranseg
      FunciÃ³n que inserta los registros grabados en MIG_bonfranseg, en la tabla
      *bf_bonfranseg de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_bonfranseg(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                        FUNCTION f_migra_sitriesgo
      FunciÃ³n que inserta los registros grabados en MIG_SITRIESGO, en la tabla
      SITRIESGO de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas  -- 23289/120321 - ECP- 03/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sitriesgo(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

/***************************************************************************
      FUNCTION f_migra_ctgar_seguro
      FunciÃ³n que inserta los registros grabados en MIG_CTGAR_SEGURO, en la tabla
      CTGAR_SEGURO de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas  -- 23289/120321 - ECP- 03/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_ctgar_seguro(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   -- FIN BUG 0018334 - 26-04-2011 - JMC
   /***************************************************************************
                        FUNCTION f_migra_garanseg
      FunciÃ³n que inserta los registros grabados en MIG_GARANSEG, en la tabla
      GARANSEG de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas  -- 23289/120321 - ECP- 03/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_garanseg(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   -- BUG : 10395 - 18-06-2009 - JMC - Proceso que determina que polizas tienen cuadro
   /***************************************************************************
                          PROCEDURE p_cuadro
        Procedimiento que despues de la carga de pregungaranseg, determina que
        pÃ³lizas tienen que tener cuadros de amortizaciÃ³n
           param in  pncarga:     NÃºmero de carga.
           param in  pntab:       NÃºmero de tabla.
     ***************************************************************************/
   PROCEDURE p_cuadro(pncarga IN NUMBER, pntab IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL');

   -- FIN BUG : 10395 - 18-06-2009 - JMC
   /***************************************************************************
                        FUNCTION f_migra_detgaranseg
      FunciÃ³n que inserta los registros grabados en MIG_DETGARANSEG, en la tabla
      DETGARANSEG de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas  -- 23289/120321 - ECP- 04/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   -- BUG 8402 - 15-05-2009 - JMC - FunciÃ³n para la migraciÃ³n de la tabla DETGARANSEG
   FUNCTION f_migra_detgaranseg(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   -- FIN BUG 8402 - 15-05-2009 - JMC
   /***************************************************************************
                        FUNCTION f_migra_comisigaranseg
      FunciÃ³n que inserta los registros grabados en MIG_COMISIGARANSEG, en la tabla
      COMISIGARANSEG de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   -- BUG 10395 - 17-06-2009 - JMC - FunciÃ³n para la migraciÃ³n de la tabla COMISIGARANSEG
   FUNCTION f_migra_comisigaranseg(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   -- FIN BUG 10395 - 17-06-2009 - JMC

   /***************************************************************************
                        FUNCTION f_migra_pregunseg
      FunciÃ³n que inserta los registros grabados en MIG_PREGUNSEG, en las tablas
      PREGUNSEG y PROGUNPOLSEG de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas  -- 23289/120321 - ECP- 04/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_pregunseg(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                        FUNCTION f_migra_preguntab
      FunciÃ³n que inserta los registros grabados en MIG_PREGUNSEGTAB, en las tablas
      PREGUNSEGTAB
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas  -- 23289/120321 - ECP- 04/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_preguntab(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                        FUNCTION f_migra_ctaseguro
      FunciÃ³n que inserta los registros grabados en MIG_CTASEGURO, en la tabla
      ctaseguro de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_ctaseguro(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

         -- BUG 34776 - 22-10-2015 - ETM - FunciÃ³n para la migraciÃ³n de MIG_CTASEGURO_SHADOW y SEGDISIN2 --INI
/***************************************************************************
      FUNCTION f_migra_ctaseguro_shadow
      FunciÃ³n que inserta los registros grabados en MIG_CTASEGURO_SHADOW, en la tabla
      ctaseguro_shadow de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_ctaseguro_shadow(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

     --FIN BUG 34776 - 22-10-2015 - ETM - FunciÃ³n para la migraciÃ³n de MIG_CTASEGURO_SHADOW y SEGDISIN2 --INI
   /***************************************************************************
                        FUNCTION f_migra_ctaseguro_libreta
      FunciÃ³n que inserta los registros grabados en MIG_CTASEGURO_LIBRETA, en la tabla
      CTASEGURO_LIBRETA de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_ctaseguro_libreta(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                        FUNCTION f_migra_pregungaranseg
      FunciÃ³n que inserta los registros grabados en MIG_PREGUNGARANSEG, en la tabla
      PREGUNGARANSEG de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas  -- 23289/120321 - ECP- 04/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_pregungaranseg(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                        FUNCTION f_migra_clausuesp
      FunciÃ³n que inserta los registros grabados en MIG_CLAUSUESP, en las tablas
      CLAUSUESP, CLAUBENSEG y CLAUSUSEG de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas  -- 23289/120321 - ECP- 04/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_clausuesp(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
     FUNCTION f_migra_age_corretaje
      FunciÃ³n que inserta los registros grabados en MIG_AGE_CORRETAJE, en las tablas
      AGE_CORRETAJE de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_age_corretaje(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                        FUNCTION f_migra_movseguro
      FunciÃ³n que inserta los registros grabados en MIG_MOVSEGURO, en las tablas
      MOVSEGURO, HISTORICOSEGUROS y DETMOVSEGURO de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas  -- 23289/120321 - ECP- 04/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_movseguro(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                          FUNCTION f_migra_recibos
        FunciÃ³n que trata y traspasa la informaciÃ³n de la tabla Intermedia
        MIG_RECIBOS (+MIG_SEGUROS), a las tablas de axis: RECIBOS y MOVRECIBO
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
           return            : 0 si valido, sino codigo error
     ***************************************************************************/
   FUNCTION f_migra_recibos(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                         FUNCTION f_migra_detrecibos
       FunciÃ³n que trata y traspasa la informaciÃ³n de la tabla Intermedia
       MIG_DETRECIBOS (+MIG_SEGUROS), a las tablas de axis: DETRECIBOS Y VDETRECIBOS
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
          return            : 0 si valido, sino codigo error
    ***************************************************************************/
   FUNCTION f_migra_detrecibos(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   -- BUG 8402 - 15-05-2009 - JMC - Se aÃ±ade funciÃ³n para la migraciÃ³n de la tabla MOVRECIBO
   /***************************************************************************
                        FUNCTION f_migra_movrecibo
      FunciÃ³n que inserta los registros grabados en MIG_MOVRECIBO, en la tabla
      movrecibo de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_movrecibo(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

/***************************************************************************
      FUNCTION f_migra_detmovrecibo
      FunciÂ¿n que inserta los registros grabados en MIG_DETMOVRECIBO, en la tabla
      movrecibo de AXIS.
         param in  pncarga:     NÂ¿mero de carga.
         param in  pntab:       NÂ¿mero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_detmovrecibo(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_detmovrecibo_parcial
      FunciÂ¿n que inserta los registros grabados en MIG_DETMOVRECIBO_PARCIAL, en la tabla
      movrecibo de AXIS.
         param in  pncarga:     NÂ¿mero de carga.
         param in  pntab:       NÂ¿mero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_detmovrecibo_parcial(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_liquidacab
      FunciÃ³n que inserta los registros grabados en MIG_LIQUIDACAB, en la tabla
      LIQUIDACAB de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_liquidacab(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

/***************************************************************************
      FUNCTION f_migra_liquidalin
      FunciÃ³n que inserta los registros grabados en MIG_LIQUIDALIN, en la tabla
      LIQUIDALIN de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_liquidalin(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

/***************************************************************************
      FUNCTION f_migra_ctactes
      FunciÃ³n que inserta los registros grabados en MIG_CTACTES, en la tabla
      CTACTES de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_ctactes(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   -- FIN BUG 8402 - 15-05-2009 - JMC
   /***************************************************************************
                        FUNCTION f_migra_agensegu
      FunciÃ³n que inserta los registros grabados en MIG_AGENSEGU, en la tabla
      agensegu de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_agensegu(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                        FUNCTION f_migra_seguros_ulk
      FunciÃ³n que inserta los registros grabados en MIG_SEGUROS_FINV, en la
      tabla seguros_ulk de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas  -- 23289/120321 - ECP- 04/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_seguros_ulk(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   -- BUG 34776 - 22-10-2015 - ETM - FunciÃ³n para la migraciÃ³n de MIG_CTASEGURO_SHADOW y SEGDISIN2
   /***************************************************************************
        FUNCTION f_migra_segdisin2
        FunciÃ³n que inserta los registros grabados en MIG_SEGDISIN2, en la
        tabla segdisin2 de AXIS.
           param in  pncarga:     NÃºmero de carga.
           param in  pntab:       NÃºmero de tabla.
           param in  ptablas      EST Simulaciones, POL PÃ³lizas
           return:                0-OK, <>0-Error
     ***************************************************************************/
   FUNCTION f_migra_segdisin2(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   --FIN BUG 34776 - 22-10-2015 - ETM - FunciÃ³n para la migraciÃ³n de MIG_CTASEGURO_SHADOW y SEGDISIN2
     /***************************************************************************
                          FUNCTION f_migra_tabvalces
        FunciÃ³n que inserta los registros grabados en MIG_TABVALCES, en la tabla
        tabvalces de AXIS.
           param in  pncarga:     NÃºmero de carga.
           param in  pntab:       NÃºmero de tabla.
           return:                0-OK, <>0-Error
     ***************************************************************************/
   FUNCTION f_migra_tabvalces(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   --INI BUG:12374 - 21-12-2009 - JMC --CreaciÃ³n funciÃ³n f_migra_prestamoseg
   /***************************************************************************
                         FUNCTION f_migra_prestamoseg
       FunciÃ³n que inserta los registros grabados en MIG_PRESTAMOSEG, en la tabla
       tabvalces de AXIS.
          param in  pncarga:     NÃºmero de carga.
          param in  pntab:       NÃºmero de tabla.
          param in  ptablas      EST Simulaciones POL PÃ³lizas  -- 23289/120321 - ECP- 04/09/2012
          return:                0-OK, <>0-Error
    ***************************************************************************/
   FUNCTION f_migra_prestamoseg(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   --FIN BUG:12374 - 21-12-2009 - JMC
   --INI BUG:12374 - 22-12-2009 - JMC - MigraciÃ³n nuevo modelo siniestros.
   /***************************************************************************
                         FUNCTION f_migra_sin_siniestro
       FunciÃ³n que inserta los registros grabados en MIG_SIN_SINIESTRO, en la tabla
       sin_siniestro de AXIS.
          param in  pncarga:     NÃºmero de carga.
          param in  pntab:       NÃºmero de tabla.
          return:                0-OK, <>0-Error
    ***************************************************************************/
   FUNCTION f_migra_sin_siniestro(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL',
      pboldaxis IN BOOLEAN DEFAULT FALSE)
      RETURN NUMBER;

   /***************************************************************************
                         FUNCTION f_migra_sin_movsiniestro
       FunciÃ³n que inserta los registros grabados en MIG_SIN_MOVSINIESTRO, en la tabla
       sin_movsiniestro de AXIS.
          param in  pncarga:     NÃºmero de carga.
          param in  pntab:       NÃºmero de tabla.
          return:                0-OK, <>0-Error
    ***************************************************************************/
   FUNCTION f_migra_sin_movsiniestro(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

/***************************************************************************
                         FUNCTION f_migra_sin_SINIESTRO_REFERENCIAS
       FunciÃ³n que inserta los registros grabados en MIG_SIN_SINIESRO_REFERENCIAS, en la tabla
       sin_tramitacion de AXIS.
          param in  pncarga:     NÃºmero de carga.
          param in  pntab:       NÃºmero de tabla.
          return:                0-OK, <>0-Error
    ***************************************************************************/
   FUNCTION f_migra_sin_siniestro_referenc(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                         FUNCTION f_migra_sin_tramitacion
       FunciÃ³n que inserta los registros grabados en MIG_SIN_TRAMITACION, en la tabla
       sin_tramitacion de AXIS.
          param in  pncarga:     NÃºmero de carga.
          param in  pntab:       NÃºmero de tabla.
          return:                0-OK, <>0-Error
    ***************************************************************************/
   FUNCTION f_migra_sin_tramitacion(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                         FUNCTION f_migra_sin_tramita_movimiento
       FunciÃ³n que inserta los registros grabados en MIG_SIN_TRAMITA_MOVIMIENTO, en la tabla
       sin_tramita_movimiento de AXIS.
          param in  pncarga:     NÃºmero de carga.
          param in  pntab:       NÃºmero de tabla.
          return:                0-OK, <>0-Error
    ***************************************************************************/
   FUNCTION f_migra_sin_tramita_movimiento(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

/***************************************************************************
      FUNCTION f_migra_sin_tramita_judicial
      FunciÃ³n que inserta los registros grabados en MIG_SIN_TRAMITA_JUDICIAL, en la tabla
      SIN_TRAMITA_JUDICIAL de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_tramita_judicial(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_sin_tram_judi_detper
      FunciÃ³n que inserta los registros grabados en MIG_SIN_TRAM_JUDI_DETPER, en la tabla
      SIN_TRAMITA_JUDICIAL_DETPER de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_tram_judi_detper(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

/***************************************************************************
      FUNCTION f_migra_sin_tram_valpret
      FunciÃ³n que inserta los registros grabados en MIG_SIN_TRAM_VALPRET, en la tabla
      SIN_TRAMITA_VALPRETENSION de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_tram_valpret(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

/***************************************************************************
      FUNCTION f_migra_sin_tramita_fiscal
      FunciÃ³n que inserta los registros grabados en MIG_SIN_TRAMITA_FISCAL, en la tabla
      SIN_TRAMITA_FISCAL de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_tramita_fiscal(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;


/***************************************************************************
      FUNCTION f_migra_sin_tram_vpretfis
      FunciÃ³n que inserta los registros grabados en MIG_SIN_TRAM_VPRETFIS, en la tabla
      SIN_TRAMITA_VALPRETENSION de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_tram_vpretfis(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

/***************************************************************************
      FUNCTION f_migra_sin_tramita_citaciones
      FunciÃ³n que inserta los registros grabados en MIG_SIN_TRAMITA_CITACIONES, en la tabla
      SIN_TRAMITA_CITACIONES de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_tramita_citaciones(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
       FUNCTION f_migra_agd_observaciones
       FunciÃ³n que inserta los registros grabados en MIG_AGD_OBSERVACIONES, en la tabla
       AGD_OBSERVACIONES de AXIS.
          param in  pncarga:     NÃºmero de carga.
          param in  pntab:       NÃºmero de tabla.
          return:                0-OK, <>0-Error
    ***************************************************************************/
   FUNCTION f_migra_agd_observaciones(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
   /***************************************************************************
                         FUNCTION f_migra_sin_tramita_agenda
       FunciÃ³n que inserta los registros grabados en MIG_SIN_TRAMITA_AGENDA, en la tabla
       sin_tramita_agenda de AXIS.
          param in  pncarga:     NÃºmero de carga.
          param in  pntab:       NÃºmero de tabla.
          return:                0-OK, <>0-Error
    ***************************************************************************/
   FUNCTION f_migra_sin_tramita_agenda(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
       FUNCTION f_migra_sin_tramita_personasrel
       FunciÃ³n que inserta los registros grabados en MIG_SIN_TRAMITA_personasrel, en la tabla
       sin_tramita_destinatario de AXIS.
          param in  pncarga:     NÃºmero de carga.
          param in  pntab:       NÃºmero de tabla.
          return:                0-OK, <>0-Error
    ***************************************************************************/
   FUNCTION f_migra_sin_tramita_personasre(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
       FUNCTION f_migra_sin_tramita_dest
       FunciÃ³n que inserta los registros grabados en MIG_SIN_TRAMITA_DEST, en la tabla
       sin_tramita_destinatario de AXIS.
          param in  pncarga:     NÃºmero de carga.
          param in  pntab:       NÃºmero de tabla.
          return:                0-OK, <>0-Error
    ***************************************************************************/
   FUNCTION f_migra_sin_tramita_dest(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                         FUNCTION f_migra_sin_tramita_reserva
       FunciÃ³n que inserta los registros grabados en MIG_SIN_TRAMITA_RESERVA, en la tabla
       sin_tramita_reserva de AXIS.
          param in  pncarga:     NÃºmero de carga.
          param in  pntab:       NÃºmero de tabla.
          return:                0-OK, <>0-Error
    ***************************************************************************/
   FUNCTION f_migra_sin_tramita_reserva(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                         FUNCTION f_migra_sin_tramita_pago
       FunciÃ³n que inserta los registros grabados en MIG_SIN_TRAMITA_PAGO, en la tabla
       sin_tramita_pago de AXIS.
          param in  pncarga:     NÃºmero de carga.
          param in  pntab:       NÃºmero de tabla.
          return:                0-OK, <>0-Error
    ***************************************************************************/
   FUNCTION f_migra_sin_tramita_pago(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL',
      pboldaxis IN BOOLEAN DEFAULT FALSE)
      RETURN NUMBER;

   /***************************************************************************
                         FUNCTION f_migra_sin_tramita_movpago
       FunciÃ³n que inserta los registros grabados en MIG_SIN_TRAMITA_MOVPAGO, en la tabla
       sin_tramita_movpago de AXIS.
          param in  pncarga:     NÃºmero de carga.
          param in  pntab:       NÃºmero de tabla.
          return:                0-OK, <>0-Error
    ***************************************************************************/
   FUNCTION f_migra_sin_tramita_movpago(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                         FUNCTION f_migra_sin_tramita_pago_gar
       FunciÃ³n que inserta los registros grabados en MIG_SIN_TRAMITA_PAGO_GAR, en la tabla
       sin_tramita_pago_gar de AXIS.
          param in  pncarga:     NÃºmero de carga.
          param in  pntab:       NÃºmero de tabla.
          return:                0-OK, <>0-Error
    ***************************************************************************/
   FUNCTION f_migra_sin_tramita_pago_gar(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
   --
   /***************************************************************************
      FUNCTION f_migra_sin_tramita_apoyo
      FunciÃ³n que inserta los registros grabados en MIG_SIN_TRAMITA_APOYO, en la tabla
      SIN_TRAMITA_APOYOS de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_tramita_apoyo(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   --INI BUG:12557 - 14-01-2010 - JMC - IncorporaciÃ³n nuevas funciones
   /***************************************************************************
                         FUNCTION f_migra_sup_diferidosseg
       FunciÃ³n que inserta los registros grabados en MIG_SUP_DIFERIDOSSEG, en la tabla
       sup_diferidosseg de AXIS.
          param in  pncarga:     NÃºmero de carga.
          param in  pntab:       NÃºmero de tabla.
          return:                0-OK, <>0-Error
    ***************************************************************************/
   FUNCTION f_migra_sup_diferidosseg(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                         FUNCTION f_migra_sup_acciones_dif
       FunciÃ³n que inserta los registros grabados en MIG_SUP_ACCIONES_DIF, en la tabla
       sup_acciones_dif de AXIS.
          param in  pncarga:     NÃºmero de carga.
          param in  pntab:       NÃºmero de tabla.
          return:                0-OK, <>0-Error
    ***************************************************************************/
   FUNCTION f_migra_sup_acciones_dif(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                        FUNCTION f_migra_pagosrenta
      FunciÃ³n que inserta los registros grabados en MIG_PAGOSRENTA, en la tabla
      pagosrenta de AXIS (PAGOSRENTA y MOVPAGREN).
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_pagosrenta(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                        FUNCTION f_migra_comisionsegu
      FunciÃ³n que inserta los registros grabados en MIG_COMISIONSEGU, en la tabla
      COMISIONSEGU de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas  -- 23289/120321 - ECP- 04/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_comisionsegu(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   --FIN BUG:12557 - 14-01-2010 - JMC
   /***************************************************************************
                        PROCEDURE p_migra_cargas
      Procedimiento que determina las cargas que estan pendientes de migrar y
      lanza dinamicamente la funciÃ³n para migrar dichas cargas.
      ctaseguro de AXIS.
         param in  pide:     Identificador de las cargas.
         param in  pncarga:  NÃºmero de carga, si NULL todas.
   ***************************************************************************/
   PROCEDURE p_migra_cargas(
      pid IN VARCHAR2 DEFAULT NULL,   --BUG:12243 - 02-12-2009 - JMC - Se aÃ±ade parametro pid
      ptipo IN VARCHAR2 DEFAULT 'M',   --BUG:14185 - 11-05-2010 - JMC - Se aÃ±ade parametro ptipo
      pncarga IN NUMBER DEFAULT NULL,
      --BUG:14185 - 11-05-2010 - JMC - Se aÃ±ade parametro pncarga
      pcestado IN VARCHAR2 DEFAULT 'RET',
      --BUG:14185 - 11-05-2010 - JMC - Se aÃ±ade parametro pcestado
      ptabla IN VARCHAR2 DEFAULT 'POL',   -- BUG 23548 -- 18/09/2012
      pcmodo IN VARCHAR DEFAULT 'GENERAL');

   --   FUNCTION f_del_mig_emp_mig(pncarga IN NUMBER)
   --      RETURN NUMBER;

   /***************************************************************************
                        PROCEDURE p_borra_tabla_mig
      Procedimiento que dada una carga, la tabla MIG  retrocede o borra la
      migraciÃ³n de dicha carga.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  pttab:       Nombre de la tabla.
   ***************************************************************************/
   PROCEDURE p_borra_tabla_mig(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      pttab IN VARCHAR2,
      ptipo IN VARCHAR2 DEFAULT 'M');

   /***************************************************************************
                        PROCEDURE p_borra_cargas
      Procedimiento que determina las cargas que estan es situaciÃ³n de ser
      retrocedidas o borradas y lanza la funciÃ³n para relizar dicha acciÃ³n.
         param in  pcestado:    Estado 'DEL' para borrar, 'RET' para retroceder
   ***************************************************************************/
   PROCEDURE p_borra_cargas(
      pcestado IN VARCHAR2,
      pncarga IN NUMBER DEFAULT NULL,
      ptipo IN VARCHAR2 DEFAULT 'M');

      /***************************************************************************
                           FUNCTION f_strstd_mig
         FunciÃ³n que elimina caracteres especiales y sustituye palabras acentuadas,
         sin acento para su comparaciÃ³n con otra cadena.
   4         param in  pstr:     Cadena a tratar
            return:             Cadena tratada
      ***************************************************************************/
   FUNCTION f_strstd_mig(pstr IN VARCHAR2)
      RETURN VARCHAR2;

   -- ini Bug 0011578 - JMF - 05-11-2009
   PROCEDURE p_mig_cesiones   /*************************************************************************
                                                                             param in pcempres   :   empresa.
                                                           param in pfefecto   :   efecto movimiento
                                                           param in pcdetrea   :   genera detall per rebut o no: (PCDETREA 0-No(defecte) / 1-Si)
                                                           param in pctanca    :   traspassar cessions al tancament o no: (PCTANCA 0-No (defecte) 1-Si)
                                                           param in pultmov    :   nomÃ©s genera les cessions del darrer moviment( pultmov = 0-NO (defecte) 1-Si)
                                                           param in puser      :   usuario necesario para reaseguro.
                                                           param in psproduc   :   producto a tratar si NULL todos
                                                        *************************************************************************/
                           (
      pcempres IN NUMBER,
      pfefecto IN DATE,
      pcdetrea IN NUMBER DEFAULT 0,
      pctanca IN NUMBER DEFAULT 0,
      pultmov IN NUMBER DEFAULT 0,
      puser IN VARCHAR2,
      psproduc IN NUMBER DEFAULT NULL   --BUG:12374 - 23-12-2009 - JMC - ParÃ¡metro producto
                                     );

   -- fin Bug 0011578 - JMF - 05-11-2009

   -- ini Bug 0011578 - JMF - 05-11-2009
   PROCEDURE p_post_instalacion_rea   /***************************************************************************
                                                                                         PROCEDURE P_POST_INSTALACION_REA
                                                                       Procedimiento que lanza tareas a realizar en la migraciÃ³n de cesiones.
                                                                           param in pcempres   :   empresa.
                                                                           param in pfefecto   :   efecto movimiento
                                                                           param in pcdetrea   :   genera detall per rebut o no: (PCDETREA 0-No(defecte) / 1-Si)
                                                                           param in pctanca    :   traspassar cessions al tancament o no: (PCTANCA 0-No (defecte) 1-Si)
                                                                           param in pultmov    :   nomÃ©s genera les cessions del darrer moviment( pultmov = 0-NO (defecte) 1-Si)
                                                                           param in puser      :   usuario necesario para reaseguro.
                                                                           param in psproduc   :   producto a tratar si NULL todos
                                                                    ***************************************************************************/
                                   (
      pcempres IN NUMBER,
      pfefecto IN DATE,
      pcdetrea IN NUMBER DEFAULT 0,
      pctanca IN NUMBER DEFAULT 0,
      pultmov IN NUMBER DEFAULT 0,
      puser IN VARCHAR2,
      psproduc IN NUMBER DEFAULT NULL   --BUG:12374 - 23-12-2009 - JMC - ParÃ¡metro producto
                                     );

   -- fin Bug 0011578 - JMF - 05-11-2009
   -- ini BUG 0012620 - 11/01/2010 - JMF - CEM - REA cessions de pagaments al procÃ©s de migraciÃ³
   PROCEDURE p_mig_pagos_ces   /*************************************************************************
                                                                               param in pcempres   :   empresa.
                                                             param in pfefecto   :   efecto movimiento
                                                             param in puser      :   usuario necesario para reaseguro.
                                                             param in psproduc   :   producto a tratar si NULL todos
                                                          *************************************************************************/
                            (
      pcempres IN NUMBER,
      pfefecto IN DATE,
      puser IN VARCHAR2,
      psproduc IN NUMBER DEFAULT NULL);

   --fin bug 0012620

   -- ini Bug 0011364 - ICV - 05-01-2010
    /***************************************************************************
                        FUNCTION f_migra_depositarias_axis
      FunciÃ³n que inserta los registros grabados en MIG_depositarias, en la tabla
      SIN_SINIESTRO de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_depositarias(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                         FUNCTION f_migra_planpensiones_axis
       FunciÃ³n que inserta los registros grabados en planpensiones, en la tabla
       SIN_SINIESTRO de AXIS.
          param in  pncarga:     NÃºmero de carga.
          param in  pntab:       NÃºmero de tabla.
          return:                0-OK, <>0-Error
    ***************************************************************************/
   FUNCTION f_migra_planpensiones(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                        FUNCTION f_migra_fonpensiones_axis
      FunciÃ³n que inserta los registros grabados en MIG_fonpensiones, en la tabla
      SIN_SINIESTRO de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_fonpensiones(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                           FUNCTION f_migra_gestoras_axis
         FunciÃ³n que inserta los registros grabados en MIG_gestoras, en la tabla
         SIN_SINIESTRO de AXIS.
            param in  pncarga:     NÃºmero de carga.
            param in  pntab:       NÃºmero de tabla.
            return:                0-OK, <>0-Error
      ***************************************************************************/
   FUNCTION f_migra_gestoras(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

    /***************************************************************************
                        FUNCTION f_migra_aseguradoras_axis
      FunciÃ³n que inserta los registros grabados en MIG_aseguradoras, en la tabla
      SIN_SINIESTRO de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_aseguradoras(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                        FUNCTION f_migra_planpensiones_axis
      FunciÃ³n que inserta los registros grabados en aseguradoras_planes, en la tabla
      SIN_SINIESTRO de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_aseguradoras_planes(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   -- fin Bug 0011364 - ICV - 05-01-2010
   -- BUG 0015640 - 06-09-2009 - JMC - FunciÃ³n para la migraciÃ³n de la tabla PER_DIRECCIONES
   /***************************************************************************
                        FUNCTION f_migra_direcciones
      FunciÃ³n que inserta los registros grabados en MIG_DIRECCIONES, en la tabla
      PER_DIRECCIONES de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas  -- 23289/120321 - ECP- 04/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_direcciones(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL',
      pmig_pk IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   -- FIN BUG 0015640 - 06-09-2009 - JMC

   -- BUG 0017015 - 31-01-2011 - JMF
   /***************************************************************************
                        FUNCTION f_migra_gescartas
      FunciÃ³n que inserta los registros grabados en MIG_GESCARTAS, en la tabla
      gescartas de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_gescartas(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   -- BUG 0017015 - 31-01-2011 - JMF
   /***************************************************************************
                        FUNCTION f_migra_devbanpresentadores
      FunciÃ³n que inserta los registros grabados en MIG_DEVBANPRESENTADORES, en la tabla
      devbanpresentadores de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_devbanpresentadores(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   -- BUG 0017015 - 31-01-2011 - JMF
   /***************************************************************************
                        FUNCTION f_migra_gescartas
      FunciÃ³n que inserta los registros grabados en MIG_DEVBANORDENANTES, en la tabla
      devbanordenantes de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_devbanordenantes(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   -- BUG 0017015 - 31-01-2011 - JMF
   /***************************************************************************
                        FUNCTION f_migra_gescartas
      FunciÃ³n que inserta los registros grabados en MIG_DEVBANRECIBOS, en la tabla
      devbanrecibos de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_devbanrecibos(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   -- BUG 20003 - 07-11-2011 - JMC - FunciÃ³nes para las migraciones de las tablas:
   -- PER_PERSONAS_REL, PER_REGIMENFISCAL y PER_VINCULOS.
   /***************************************************************************
                        FUNCTION f_migra_personas_rel
      FunciÃ³n que inserta los registros grabados en MIG_PERSONAS_REL, en la
      tabla de relaciones de personas de AXIS. (PER_PERSONAS_REL)
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_personas_rel(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                        FUNCTION f_migra_regimenfiscal
      FunciÃ³n que inserta los registros grabados en MIG_REGIMENFISCAL, en la
      tabla de regimen fiscales de personas de AXIS. (PER_REGIMENFISCAL)
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas  -- 23289/120321 - ECP- 05/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_regimenfiscal(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                        FUNCTION f_migra_vinculos
      FunciÃ³n que inserta los registros grabados en MIG_VINCULOS, en la
      tabla de vinculos de personas de AXIS. (PER_VINCULOS)
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas  -- 23289/120321 - ECP- 05/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_vinculos(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   -- FIN BUG 20003 - 07-11-2011 - JMC
   /***************************************************************************
                        FUNCTION f_migra_empleados
      FunciÃ³n que inserta los registros grabados en MIG_EMPLEADOS, en la
      tabla de empleados de AXIS. (EMPLEADOS)
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_empleados(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                        FUNCTION f_migra_representantes
      FunciÃ³n que inserta los registros grabados en MIG_REPRESENTANTES, en la
      tabla de representantes de AXIS. (REPRESENTANTES)
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_representantes(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                        FUNCTION f_migra_productos_empleados
      FunciÃ³n que inserta los registros grabados en MIG_PRODUCTOS_EMPLEADOS, en la
      tabla de productos por empleados de AXIS. (PRODUCTOS_EMPLEADOS)
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_productos_empleados(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                        FUNCTION f_migra_tipo_empleados
      FunciÃ³n que inserta los registros grabados en MIG_TIPO_EMPLEADOS, en la
      tabla de tipos de empleados de AXIS. (TIPO_EMPLEADOS)
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_tipo_empleados(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                        FUNCTION f_migra_detprimas
      FunciÃ³n que inserta los registros grabados en MIG_DETPRIMAS, en la tabla
      DETPRIMAS de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas  -- 23289/120321 - ECP- 05/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   -- Bug 21121 - APD - 22/02/2012 - se crea la funcion
   FUNCTION f_migra_detprimas(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   -- Bug 21686 - JMC - 25/05/2012 - Se aÃ±ade funcion para migrar GARANDETCAP
   /***************************************************************************
                        FUNCTION f_migra_garandetcap
      FunciÃ³n que inserta los registros grabados en MIG_GARANDETCAP, en la tabla
      GARANDETCAP de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas  -- 23289/120321 - ECP- 05/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_garandetcap(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

    -- Fin Bug 21686 - JMC - 25/05/2012
    --bfp bug 21947 ini
    /***************************************************************************
                        FUNCTION f_migra_garansegcom
      FunciÃ³n que inserta los registros grabados en MIG_GARANSEGCOM, en la tabla
      PREGUNGARANSEG de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas  -- 23289/120321 - ECP- 05/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_garansegcom(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
                         FUNCTION f_migra_benespseg
       FunciÃ³n que inserta los registros grabados en MIG_BENESPSEG, en la
       tabla de empleados de AXIS. (BENESPSEG)
          param in  pncarga:     NÃºmero de carga.
          param in  pntab:       NÃºmero de tabla.
          return:                0-OK, <>0-Error
    ***************************************************************************/
   FUNCTION f_migra_benespseg(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

--bfp bug 21947 fi

   -- Inicio Bug:24744-SCO-20130917
/***************************************************************************
   FUNCTION f_mig_validacion
   funciÃ³n que realiza las validaciones de la tabla MIG_VALIDACION para cada producto del seguro
      psseguro       cÃ³digo del seguro
      ptablas        tablas EST o SEG
   ***************************************************************************/
   FUNCTION f_mig_validacion(
      psseguro IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      psproduc IN NUMBER,
      pmens OUT VARCHAR2)
      RETURN NUMBER;

-- Fin Bug:24744-SCO-20130917

   /***************************************************************************
      FUNCTION f_trata_preguntas_migracion - SCO-20131017
      funciÃ³n que aÃ±ade las garantÃ­as que faltan y comprueba las preguntas de pÃ³liza, riesgo y garantÃ­as
      para las pÃ³lizas cargadas por fichero en modo migraciÃ³n
         psseguro       cÃ³digo del seguro
   ***************************************************************************/
   FUNCTION f_trata_preguntas_migracion(psseguro IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /***************************************************************************
       FUNCTION f_migra_antiguedades
       funciÃ³n para migrar las antiguedades

       Bug 29738/163540 - 27/02/2014 - AMC
    ***************************************************************************/
   FUNCTION f_migra_antiguedades(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL',
      pmig_pk IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

/***************************************************************************
      FUNCTION f_migra_gescobros
      FunciÃ³n que inserta los registros grabados en MIG_GESCOBROS, en la tabla
      ASEGURADOS de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_gescobros(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

/***************************************************************************
      FUNCTION f_migra_coacuadro
      FunciÃ³n que inserta los registros grabados en MIG_COACUADRO, en la tabla
      COACUADRO de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_coacuadro(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

/***************************************************************************
      FUNCTION f_migra_coacedido
      FunciÃ³n que inserta los registros grabados en MIG_COACEDIDO, en la tabla
      COACEDIDO de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_coacedido(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_ctacoaseguro
      FunciÃ³n que inserta los registros grabados en MIG_CTACOASEGURO, en la tabla
      CTACOASEGURO de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas  -- 23289/120321 - ECP- 04/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_ctacoaseguro(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_detalle_riesgos
      FunciÃ³n que inserta los registros grabados en MIG_DETALLE_RIESGOS, en la tabla
      ASEGURADOS_INNOM de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_detalle_riesgos(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

/***************************************************************************
      FUNCTION f_migra_convenio_seg
      FunciÃ³n que inserta los registros grabados en MIG_CNV_CONV_EMP_SEG, en la tabla
      CNV_CONV_EMP_SEG de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_convenio_seg(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

--INI -- ETM --BUG 34776/202076--
   /***************************************************************************
      FUNCTION f_migra_bloqueoseg
      FunciÃ³n que inserta los bloqueos grabados en MIG_BLOQUEOSEG, en las distintas
      tablas de agentes de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_bloqueoseg(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

--FIN -- ETM --BUG 34776/202076--

   --INI -- JLB --BUG 34776/213932--
   /***************************************************************************
      FUNCTION f_migra_psu_retenidas
      FunciÃ³n que inserta las polizas retenidas en MIG_PSU_RETENIDAS, en PSU_RETENIDAS
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_psu_retenidas(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

-- FIN -- JLB

   -- ini rllf 28092015 migrar participaciÃ³n de beneficios
/***************************************************************************
      FUNCTION f_migra_pbex
      FunciÃ³n que inserta los registros grabados en MIG_COACEDIDO, en la tabla
      COACEDIDO de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_pbex(pncarga IN NUMBER, pntab IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

-- fin rllf 28092015 migrar participaciÃ³n de beneficios

/***************************************************************************
      FUNCTION f_migra_pppc
      FunciÃ³n que inserta los registros grabados en MIG_PPPC, en la tabla
      PPPC de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas  -- 23289/120321 - ECP- 04/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_pppc(pncarga IN NUMBER, pntab IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

/***************************************************************************
      FUNCTION f_migra_ptpplp
      FunciÃ³n que inserta los registros grabados en MIG_PTPPLP, en la tabla
      PTPPLP de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_ptpplp(pncarga IN NUMBER, pntab IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_ppna
      FunciÃ³n que inserta los registros grabados en MIG_PPNA, en la tabla
      PPNA de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_ppna(pncarga IN NUMBER, pntab IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_prpc
      FunciÃ³n que inserta los registros grabados en MIG_PRPC, en la tabla
      PRPC de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_prpc(pncarga IN NUMBER, pntab IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
   -- ini rllf 05102015 migrar reemplazos de pÃ³lizas
/***************************************************************************
      FUNCTION f_migra_pbex
      FunciÃ³n que inserta los registros grabados en MIG_REEMPLAZOS, en la tabla
      COACEDIDO de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_reemplazos(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
-- fin rllf 05102015 migrar reemplazos de pÃ³lizas
   /***************************************************************************
      FUNCTION f_migra_personas_rel
      FunciÃ³n que inserta los registros grabados en MIG_PERSONAS_REL, en la
      tabla de relaciones de personas de AXIS. (PER_PERSONAS_REL)
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_prof_profesionales(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_sin_prof_indicadores
      FunciÃ³n que inserta los registros grabados en MIG_PROF_INDICADORES, en la
      tabla de relaciones de personas de AXIS. (SIN_PROF_INDICADORES)
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_prof_indicadores(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_sin_prof_rol
      FunciÃ³n que inserta los registros grabados en MIG_PROF_ROL, en la
      tabla de relaciones de personas de AXIS. (SIN_PROF_ROL)
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_prof_rol(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_sin_prof_contactos
      FunciÃ³n que inserta los registros grabados en MIG_PROF_CONTACTOS, en la
      tabla de relaciones de personas de AXIS. (SIN_PROF_CONTACTOS)
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_prof_contactos(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_sin_prof_ccc
      FunciÃ³n que inserta los registros grabados en MIG_SIN_PROF_CCC, en la
      tabla de relaciones de personas de AXIS. (SIN_PROF_CCC)
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_prof_ccc(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_sin_prof_repre
      FunciÃ³n que inserta los registros grabados en MIG_SIN_PROF_REPRE, en la
      tabla de relaciones de personas de AXIS. (SIN_PROF_REPRE)
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_prof_repre(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_sin_prof_sede
      FunciÃ³n que inserta los registros grabados en MIG_SIN_PROF_SEDE, en la
      tabla de relaciones de personas de AXIS. (SIN_PROF_SEDE)
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_prof_sede(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_sin_prof_estados
      FunciÃ³n que inserta los registros grabados en MIG_SIN_PROF_ESTADOS, en la
      tabla de relaciones de personas de AXIS. (SIN_PROF_ESTADOS)
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_prof_estados(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_sin_prof_zonas
      FunciÃ³n que inserta los registros grabados en MIG_SIN_PROF_ZONAS, en la
      tabla de relaciones de personas de AXIS. (SIN_PROF_ZONAS)
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_prof_zonas(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_sin_prof_carga
      FunciÃ³n que inserta los registros grabados en MIG_SIN_PROF_CARGA, en la
      tabla de relaciones de personas de AXIS. (SIN_PROF_CARGA)
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_sin_prof_carga(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
   FUNCTION f_migra_sin_prof_observaciones(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
   /***************************************************************************
      FUNCTION f_migra_contragarantias
      FunciÃ³n que inserta la informaciÃ³n de contragarantÃ­as
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_contragarantias(pncarga IN NUMBER,
                                    pntab   IN NUMBER,
                                    ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
   --
   /***************************************************************************
      FUNCTION f_migra_tipos_indicadores
      FunciÃ³n que inserta la informaciÃ³n de Tipos de Indicadores
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_tipos_indicadores(pncarga IN NUMBER,
                                      pntab   IN NUMBER,
                                      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_companias
      FunciÃ³n que inserta los registros grabados en MIG_COMPANIAS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_companias(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_codicontratos
      FunciÃ³n que inserta los registros grabados en MIG_CODICONTRATOS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_codicontratos(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_contratos
      FunciÃ³n que inserta los registros grabados en MIG_CONTRATOS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_contratos(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_tramos
      FunciÃ³n que inserta los registros grabados en MIG_TRAMOS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_tramos(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_cuadroces
      FunciÃ³n que inserta los registros grabados en MIG_CUADROCES.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_cuadroces(
      pncarga IN NUMBER,
      pntab IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_clausulas_reas
      FunciÃ³n que inserta los registros grabados en MIG_BUREAU, en la tabla
      BUREAU de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas  -- 23289/120321 - ECP- 04/09/2012
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_clausulas_reas(pncarga IN NUMBER, pntab IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
   RETURN NUMBER;
   --
   /***************************************************************************
      FUNCTION f_migra_ctatecnica
      FunciÃ³n que inserta los registros grabados en MIG_CTATECNICA, en la tabla
      CTATECNICA de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_ctatecnica(pncarga IN NUMBER, pntab IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_cesionesrea
      FunciÃ³n que inserta los registros grabados en MIG_CESIONESREA, en la tabla
      CESIONESREA de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_cesionesrea(pncarga IN NUMBER, pntab IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_det_cesionesrea
      FunciÃ³n que inserta los registros grabados en MIG_CESIONESREA, en la tabla
      CESIONESREA de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_det_cesionesrea(pncarga IN NUMBER, pntab IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_det_cesionesrea
      FunciÃ³n que inserta los registros grabados en MIG_CUAFACUL, en la tabla
      CUAFACUL de iAXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_cuafacul(pncarga IN NUMBER, pntab IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_cuacesfac
      FunciÃ³n que inserta los registros grabados en MIG_CUAFACUL, en la tabla
      CUAFACUL de iAXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_cuacesfac(pncarga IN NUMBER, pntab IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_eco_tipocambio
      FunciÃ³n que inserta los registros grabados en MIG_ECO_TIPOCAMBIO, en la tabla
      ECO_TIPOCAMBIO de AXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_eco_tipocambio(pncarga IN NUMBER, pntab IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
   RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_fin_general
      FunciÃ³n que inserta los registros grabados en MIG_FIN_GENERAL, en la tabla
      FIN_GENERAL de iAXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_fin_general(pncarga IN NUMBER, pntab IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_fin_d_renta
      FunciÃ³n que inserta los registros grabados en MIG_FIN_D_RENTA, en la tabla
      FIN_D_RENTA de iAXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_fin_d_renta(pncarga IN NUMBER, pntab IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_fin_endeudamiento
      FunciÃ³n que inserta los registros grabados en MIG_FIN_ENDEUDAMIENTO, en la tabla
      FIN_ENDEUDAMIENTO de iAXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_fin_endeudamiento(pncarga IN NUMBER, pntab IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_fin_indicadores
      FunciÃ³n que inserta los registros grabados en MIG_FIN_INDICADORES, en la tabla
      FIN_INDICADORES de iAXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_fin_indicadores(pncarga IN NUMBER, pntab IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_fin_parindicadores
      FunciÃ³n que inserta los registros grabados en MIG_FIN_PARINDICADORES, en la tabla
      FIN_PARAMETROS de iAXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_fin_parindicadores(pncarga IN NUMBER, pntab IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
/***************************************************************************
      FUNCTION f_migra_datsarlaft
      FunciÃ³n que inserta los registros grabados en MIG_DATSARLAFT, en la tabla
      DATSARLAFT de iAXIS.
         param in  pncarga:     NÃºmero de carga.
         param in  pntab:       NÃºmero de tabla.
         param in  ptablas      EST Simulaciones POL PÃ³lizas
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_migra_datsarlaft(pncarga IN NUMBER, pntab IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
   /***************************************************************************
                        PROCEDURE p_migra_cargas_uni
      Procedimiento que realiza las cargas definitivas en la migracion unitaria.
      ctaseguro de AXIS.
         param in  pide:     Identificador de las cargas.
         param in  pncarga:  NÃºmero de carga, si NULL todas.
   ***************************************************************************/
   PROCEDURE p_migra_cargas_uni(
      pid IN VARCHAR2 DEFAULT NULL,   --BUG:12243 - 02-12-2009 - JMC - Se aÃ±ade parametro pid
      ptipo IN VARCHAR2 DEFAULT 'M',   --BUG:14185 - 11-05-2010 - JMC - Se aÃ±ade parametro ptipo
      pncarga IN NUMBER DEFAULT NULL,
      --BUG:14185 - 11-05-2010 - JMC - Se aÃ±ade parametro pncarga
      pcestado IN VARCHAR2 DEFAULT 'RET',
      --BUG:14185 - 11-05-2010 - JMC - Se aÃ±ade parametro pcestado
      ptabla IN VARCHAR2 DEFAULT 'POL',   -- BUG 23548 -- 18/09/2012
      pcmodo IN VARCHAR DEFAULT 'GENERAL');

   FUNCTION f_pre_valida_migra(pid IN VARCHAR2) RETURN NUMBER;

   PROCEDURE p_borra_cargas_uni( pcestado IN VARCHAR2,
                                pncarga IN NUMBER,
                                ptipo IN VARCHAR2 DEFAULT 'M');

   PROCEDURE p_migra_cargas_def(
      pid IN VARCHAR2 DEFAULT NULL,
      --BUG:12243 - 02-12-2009 - JMC - Se aÃ±ade parametro pid
      ptipo IN VARCHAR2 DEFAULT 'M',
      --BUG:14185 - 11-05-2010 - JMC - Se aÃ±ade parametro ptipo
      pncarga IN NUMBER DEFAULT NULL,
      --BUG:14185 - 11-05-2010 - JMC - Se aÃ±ade parametro pncarga
      pcestado IN VARCHAR2 DEFAULT 'RET',
      --BUG:14185 - 11-05-2010 - JMC - Se aÃ±ade parametro pcestado
      ptabla IN VARCHAR2 DEFAULT 'POL',   -- BUG 23548 -- 18/09/2012,
      pcmodo IN VARCHAR DEFAULT 'GENERAL');
    PROCEDURE p_borra_cargas_def;
    FUNCTION f_migra_planillas(pncarga IN NUMBER, pntab IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
    FUNCTION f_migra_comrecibo(pncarga IN NUMBER, pntab IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
    FUNCTION f_migra_fin_general_det(pncarga IN NUMBER, pntab IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
    FUNCTION f_migra_ctapb(pncarga IN NUMBER, pntab IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
    FUNCTION f_migra_per_indicadores(pncarga IN NUMBER, pntab IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
    FUNCTION f_migra_pagador_alt(pncarga IN NUMBER, pntab IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
    FUNCTION f_migra_psucontrolseg(pncarga IN NUMBER, pntab IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
    --7782-18 FUNCION PARA RESERVADET DE MIGRACION
    FUNCTION f_ins_reservadet( pnsinies  IN sin_siniestro.nsinies%TYPE,
                               pidres    IN NUMBER,
                               pnmovres  IN NUMBER,
                               pfmovres  IN DATE,
                               pcmovres  IN NUMBER,
                               pcmonres  IN VARCHAR2,
                               pcierre   IN NUMBER,
                               pireserva IN NUMBER) RETURN NUMBER;
    --7782-18 FUNCION PARA RESERVADET DE MIGRACION
    FUNCTION f_ins_reserva(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      pctipres IN NUMBER,
      pcgarant IN NUMBER,
      pccalres IN NUMBER,
      pfmovres IN DATE,
      pcmonres IN VARCHAR2,
      pireserva IN NUMBER,
      pipago IN NUMBER,
      picaprie IN NUMBER,
      pipenali IN NUMBER,
      piingreso IN NUMBER,
      pirecobro IN NUMBER,
      pfresini IN DATE,
      pfresfin IN DATE,
      pfultpag IN DATE,
      psidepag IN NUMBER,
      piprerec IN NUMBER,
      pctipgas IN NUMBER,
      pnmovres IN OUT NUMBER,
      pcmovres IN NUMBER,   --Bug 31294/174788:NSS:22/05/2014
      pifranq IN NUMBER DEFAULT NULL,   --Bug 27059:NSS:03/06/2013
      pndias IN NUMBER DEFAULT NULL,   --Bug 27487/159742:NSS:26/11/2013
      pitotimp IN NUMBER DEFAULT NULL,
      pitotret IN NUMBER DEFAULT NULL,   -- 24637/0147756:NSS:20/03/2014
      piva_ctipind IN NUMBER DEFAULT NULL,   -- 24637/0147756:NSS:20/03/2014
      pretenc_ctipind IN NUMBER DEFAULT NULL,   -- 24637/0147756:NSS:20/03/2014
      preteiva_ctipind IN NUMBER DEFAULT NULL,   -- 24637/0147756:NSS:20/03/2014
      preteica_ctipind IN NUMBER DEFAULT NULL,   -- 24637/0147756:NSS:20/03/2014
      pcalcfranq IN NUMBER DEFAULT NULL,   -- 29801/0183298:JTT:09/09/2014
      pcsolidaridad IN NUMBER DEFAULT NULL,   -- CONF-431 IGIL
      pmigracion IN NUMBER DEFAULT 0) RETURN NUMBER;
    FUNCTION f_migra_sin_tram_estsin(pncarga IN NUMBER, pntab IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
    FUNCTION f_migra_pregunsini(pncarga IN NUMBER, pntab IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;
END pac_mig_axis_conf;
/