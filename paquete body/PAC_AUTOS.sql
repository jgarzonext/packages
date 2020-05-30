--------------------------------------------------------
--  DDL for Package Body PAC_AUTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_AUTOS" AS
/******************************************************************************
   NOMBRE:       PAC_AUTOS
   PROPÓSITO:  Funciones para realizar una conexión
               a base de datos de la capa de negocio

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        02/03/2009   XVM               1. Creación del package.
   2.0        07/01/2013   MDS               2. 0025458: LCOL_T031-LCOL - AUT - (ID 279) Tipos de placa (matr?cula)
   3.0        17/01/2013   DCT               3. 0025546: LCOL_T031- LCOL - AUT - (id 322) identificaci?n vehicular (vin)
   4.0        18/01/2013   DCT               4. 0025625: LCOL - AUT - (id 427) Número de motor
   5.0        31/01/2013   DCT               5. 0025628: LCOL_T031-LCOL - AUT - (ID 278 id 85) Control duplicidad matriculas
   6.0        15/03/2013   DCT               6. 0026435: LCOL - TEC - control de duplicidad
   7.0        02/04/2013   DCT               7. 0026419: LCOL - TEC - Revisión Q-Trackers Fase 3A
   8.0        26/03/2013   ECP               6. 0025202: LCOL_T031 - Adaptar pantalla riesgo - autos. Id 428
   9.0        26/04/2013   FAL               9. 0026785: RSAG101 - Producto RC Argentina. Incidencias (22/4)
   10.0       28/10/2013   RCL               10. 0028455: LCOL_T031- TEC - Revisión Q-Trackers Fase 3A II
   11.0       18/12/2013   JDS               11. 0029315: LCOL_T031-Revisi?n Q-Trackers Fase 3A III
   12.0       15/05/2014   ECP               12. 0031204/0012636: ESTRUCTURA PLACA MT
   13.0       18/06/2014   ECP               13. 0031650/0013061: Estructura Placa motocarro
   14.0       30/07/2014   ECP               14. 0032013/0013821: LONGITUD PLACA EXTRANJERA
   15.0       20/03/2015   JRN               15. 0017327: Formato placa para motocarros 3 letras 2 números
******************************************************************************/

   /*************************************************************************
      FUNCTION f_valida_version
         Funció que valida determinats conceptes de la versió
         param in pcmarca   : Codi de la marca
         param in pcmodelo  : Codi del modelo
         param in pctipveh  : Codi tipo vehícle
         param in pcclaveh  : Codi classe vehícle
         param in pcversion : Codi de la versió
         param in ptversion : Descripció versió
         param in ptvarian  : Complement a la versió (en 2ª categoria)
         param in pnpuerta  : Número de portes totals en turismes
         param in pnpuertl  : Número de portes laterals dels furgons
         param in pnpuertt  : Número de portes del darrera dels furgons
         param in pflanzam  : Data del llançament. Format mes/any (mm/aaaa)
         param in pntara    : Pes en buit
         param in pnpma     : Pes Màxim Admès
         param in pnvolcar  : Volum de carga en els furgons
         param in pnlongit  : Longitud del vehícle
         param in pnvia     : Via davantera
         param in pnneumat  : Amplada de pneumàtic davanter
         param in pcvehcha  : Descripció xassis
         param in pcvehlog  : Descripció longitud
         param in pcvehacr  : Descripció tacament
         param in pcvehcaj  : Descripció de caixa
         param in pcvehtec  : Descripció de sostre
         param in pcmotor   : Tipus de motor (Gasolina, Diesel,  Elèctric, etc)
         param in pncilind  : Cilindrada del motor
         param in pnpotecv  : Poténcia del vehícle
         param in pnpotekw  : Poténcia del vehícle
         param in pnplazas  : Número màxim de places
         param in pnace100  : Temps d'acceleració de 0 a 100 Km/h.
         param in pnace400  : Temps d'acceleració de 0 a 400 metres
         param in pnveloc   : Velocitat màxima
         param in pcvehb7   : Indica si ve de base set o no
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_valida_version(
      pcmarca IN VARCHAR2,
      pcmodelo IN VARCHAR2,
      pctipveh IN VARCHAR2,
      pcclaveh IN VARCHAR2,
      pcversion IN VARCHAR2,
      ptversion IN VARCHAR2,
      pnpuerta IN NUMBER,
      pflanzam IN DATE,
      pntara IN NUMBER,
      pnpma IN NUMBER,
      pcmotor IN VARCHAR2,
      pncilind IN NUMBER,
      pnpotecv IN NUMBER,
      pnpotekw IN NUMBER,
      pnplazas IN NUMBER,
      pcvehb7 IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_AUTOS.f_valida_version';
      vparam         VARCHAR2(500)
         := 'parámetros - pcmarca: ' || pcmarca || ' pcmodelo:' || pcmodelo || ' pctipveh:'
            || pctipveh || ' pcclaveh:' || pcclaveh || ' pcversion:' || pcversion
            || ' ptversion:' || ptversion || ' pnpuerta:' || pnpuerta || ' pflanzam:'
            || pflanzam || ' pntara:' || pntara || ' pnpma:' || pnpma || ' pcmotor:'
            || pcmotor || ' pncilind:' || pncilind || ' pnpotecv:' || pnpotecv || ' pnpotekw:'
            || pnpotekw || ' pnplazas:' || pnplazas || ' pcvehb7:' || pcvehb7;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      IF pcmarca IS NULL THEN
         RETURN 9000995;   -- Marca de vehícle no informat
      ELSIF pcmodelo IS NULL THEN
         RETURN 9000996;   -- Model de vehícle no informat
      ELSIF ptversion IS NULL THEN
         RETURN 9001125;   -- Descripció de la versió no informada
      ELSIF pcclaveh IS NULL THEN
         RETURN 9000513;   -- Classe de vehicle no informat
      ELSIF pctipveh IS NULL THEN
         RETURN 9000994;   -- Tipus de vehícle no informat
      ELSIF pflanzam IS NULL THEN
         RETURN 9001126;   -- Data llançament no informada
      ELSIF pcmotor IS NULL THEN
         RETURN 9001127;   -- Tipus motor no informat
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9001128;   --Error validar la versió
   END f_valida_version;

   -- Bug 25458 - MDS - 07/01/2013 : nueva función que valida el formato de un campo
   FUNCTION f_valida_formato_campo(pcampo IN VARCHAR2, pformato IN VARCHAR2)
      RETURN NUMBER IS
      i              NUMBER := 1;
      v_caracter     VARCHAR2(1);
      v_formato      VARCHAR2(1);
   BEGIN
      IF LENGTH(pcampo) <> LENGTH(pformato) THEN
         RETURN 1;   -- Formato incorrecto
      END IF;

      WHILE i <= LENGTH(pcampo) LOOP
         v_caracter := SUBSTR(pcampo, i, 1);
         v_formato := SUBSTR(pformato, i, 1);

         -- el formato del carácter tiene que ser Numérico
         IF v_formato = 'N'
            AND INSTR('1234567890', v_caracter) = 0 THEN
            RETURN 1;
         -- el formato del carácter tiene que ser Letra
         ELSIF v_formato = 'L'
               AND INSTR('QWERTYUIOPASDFGHJKLZXCVBNM', UPPER(v_caracter)) = 0 THEN
            RETURN 1;
         ELSIF v_formato = 'C'   -- BUG 26968/0147424 - FAL - 25/06/2013 -- No admite vocales
               AND INSTR('QWRTYPSDFGHJKLZXCVBNM', UPPER(v_caracter)) = 0 THEN
            RETURN 1;
         -- tiene que ser exclusivamente el carácter
         --ELSE  -- BUG 0025412 - FAL - 21/01/2013
         -- ELSIF v_formato NOT IN('L', 'N') THEN  -- BUG 26968/0147424 - FAL - 25/06/2013 -- No admite vocales
         ELSIF v_formato NOT IN('L', 'N', 'C') THEN
            -- FI BUG 0025412
            IF v_caracter <> v_formato THEN
               RETURN 1;
            END IF;
         END IF;

         i := i + 1;
      END LOOP;

      RETURN 0;
   END f_valida_formato_campo;

   -- Bug 25458 - MDS - 07/01/2013 : nueva función que valida el formato de la matrícula
   FUNCTION f_valida_ctipmat(
      pctipmat IN NUMBER,
      pcmatric IN VARCHAR2,
      pcversion IN VARCHAR2,
      pctipveh IN VARCHAR2)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_AUTOS.f_valida_ctipmat';
      vparam         VARCHAR2(500)
         := 'parámetros - pctipmat: ' || pctipmat || ' pcmatric: ' || pcmatric
            || ' pcversion: ' || pcversion || ' pctipveh: ' || pctipveh;
      vpasexec       NUMBER(8) := 0;
      v_valida_ctipmat NUMBER := 0;
      v_longitud_cmatric NUMBER := 0;
      v_numerror_longitud NUMBER := 9904745;
      v_numerror_formato NUMBER := 9904746;
   BEGIN
      vpasexec := 1;
      -- valida que la matrícula no tenga caracteres prohibidos
      v_valida_ctipmat := pac_validaciones.f_valida_campo(pac_md_common.f_get_cxtempresa(),
                                                          'CMATRIC', pcmatric);

      IF v_valida_ctipmat <> 0 THEN
         RETURN v_numerror_formato;
      END IF;

      vpasexec := 2;
      -- valida el formato de la matrícula, en función del tipo de matrícula y el tipo vehículo
      v_longitud_cmatric := LENGTH(pcmatric);
      --
      vpasexec := 3;

      -- Placa tipo TL (L)
      IF pctipmat = 11 THEN
         IF v_longitud_cmatric <> 6 THEN
            RETURN v_numerror_longitud;
         END IF;

         -- formato correcto : LLNNNN
         IF f_valida_formato_campo(pcmatric, 'TLNNNN') <> 0 THEN
            RETURN v_numerror_formato;
         END IF;
      END IF;

      vpasexec := 4;

      -- Placa tipo Colombia (C)
      IF pctipmat = 12 THEN
         -- Ini 31204/0012636 -- ECP -- 15/05/2014
         IF v_longitud_cmatric <> 6 THEN
            IF pctipveh IN('17', '18', '19') THEN   -- BUG 0017327 – 20/03/2015 - jrn - Formato placa para motocarros 3 letras 2 números
               IF v_longitud_cmatric <> 5 THEN
                  RETURN v_numerror_longitud;
               END IF;
            ELSE
               RETURN v_numerror_longitud;
            END IF;
         -- Fin 31204/0012636 -- ECP -- 15/05/2014
         END IF;

         -- Remolques
         IF pctipveh IN('23', '25') THEN
            -- formato correcto : RLLLLL
            IF f_valida_formato_campo(pcmatric, 'RNNNNN') <> 0 THEN
               RETURN v_numerror_formato;
            END IF;
         -- Motocarro
         ELSIF pctipveh = '19' THEN
            -- formato correcto : NNNLLL
            IF f_valida_formato_campo(pcmatric, 'NNNLLL') <> 0 THEN
               --Ini 31650/0013061 -- ECP -- 18/06/2014
               IF f_valida_formato_campo(pcmatric, 'LLLNNL') <> 0 THEN
                  IF f_valida_formato_campo(pcmatric, 'LLLNNN') <> 0 THEN
                     -- INI BUG 0017327 – 20/03/2015 - JRN - Formato placa para motocarros 3 letras 2 números
                     IF f_valida_formato_campo(pcmatric, 'LLLNN') <> 0 THEN
                        RETURN v_numerror_formato;
                     END IF;
                  -- FIN BUG 0017327 – 20/03/2015 - JRN
                  END IF;
               END IF;
            --Fin 31650/0013061 -- ECP -- 18/06/2014
            END IF;
         -- Motocicleta
         -- Ini 31204/0012636 -- ECP -- 15/05/2014
         ELSIF pctipveh IN('17', '18') THEN
            IF v_longitud_cmatric <> 6 THEN
               IF v_longitud_cmatric <> 5 THEN
                  RETURN v_numerror_longitud;
               END IF;
            END IF;

            -- formato correcto : LLLNNL
            IF f_valida_formato_campo(pcmatric, 'LLLNNL') <> 0 THEN
               -- formato correcto : LLLNN
               IF f_valida_formato_campo(pcmatric, 'LLLNN') <> 0 THEN
                  RETURN v_numerror_formato;
               END IF;
            END IF;
            -- Fin 31204/0012636 -- ECP -- 15/05/2014
         -- Para el resto
         ELSE
            -- formato correcto : LLLNNN
            IF f_valida_formato_campo(pcmatric, 'LLLNNN') <> 0 THEN
               RETURN v_numerror_formato;
            END IF;
         END IF;
      END IF;

      vpasexec := 5;

      -- Placa tipo extranjera
      IF pctipmat = 13 THEN
         -- Ini 32013/0013821 --ECP-- 30/07/2014  Se cambia IF v_longitud_cmatric <> 10 por
         IF v_longitud_cmatric > 10 THEN
            RETURN v_numerror_longitud;
         END IF;
      -- Fin 32013/0013821 --ECP-- 30/07/2014
         --Este tipo de matricula puedes ser alfanumerico
--         -- formato correcto : LLLLLLLLLL
--         IF f_valida_formato_campo(pcmatric, 'LLLLLLLLLL') <> 0 THEN
--            RETURN v_numerror_formato;
--         END IF;
      END IF;

      vpasexec := 6;

      -- Placa uso diplomático
      IF pctipmat = 14 THEN
         IF v_longitud_cmatric <> 6 THEN
            RETURN v_numerror_longitud;
         END IF;

         -- formato correcto : LLNNNN
         IF f_valida_formato_campo(pcmatric, 'LLNNNN') <> 0 THEN
            RETURN v_numerror_formato;
         END IF;
      END IF;

      vpasexec := 7;

      -- Placa tipo importación temporal
      IF pctipmat = 15 THEN
         IF v_longitud_cmatric <> 5 THEN
            RETURN v_numerror_longitud;
         END IF;

         -- formato correcto : LNNNN
         IF f_valida_formato_campo(pcmatric, 'LNNNN') <> 0 THEN
            RETURN v_numerror_formato;
         END IF;
      END IF;

      -- BUG 0025412 - FAL - 11/01/2013
      -- Placa tipo Chilena
      IF pctipmat = 16 THEN
         IF v_longitud_cmatric <> 6 THEN
            RETURN v_numerror_longitud;
         END IF;

         -- formato correcto : LNNNN
         -- Bug 0026968 - FAL - 30/05/2013
         -- IF f_valida_formato_campo(pcmatric, 'LLNNNN') <> 0 THEN
         IF f_valida_formato_campo(pcmatric, 'CCNNNN') <> 0
            -- AND f_valida_formato_campo(pcmatric, 'LLLLNN') <> 0 THEN  -- BUG 26968/0147424 - FAL - 25/06/2013 -- No admite vocales
            AND f_valida_formato_campo(pcmatric, 'CCCCNN') <> 0 THEN
            -- FI Bug 0026968
            RETURN v_numerror_formato;
         END IF;
      END IF;

      -- Placa tipo Chilena PPU
      IF pctipmat = 17 THEN
         IF v_longitud_cmatric <> 6 THEN
            RETURN v_numerror_longitud;
         END IF;

         -- formato correcto : LNNNN
         IF f_valida_formato_campo(pcmatric, 'LLLLNN') <> 0 THEN
            RETURN v_numerror_formato;
         END IF;
      END IF;

      -- FI BUG 0025412
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN v_numerror_formato;   --Error validar matrícula
   END f_valida_ctipmat;

   -- Bug 25458 - MDS - 07/01/2013 : nueva función que valida el formato del chasis
   FUNCTION f_valida_chasis(pcchasis IN VARCHAR2)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_AUTOS.f_valida_chasis';
      vparam         VARCHAR2(500) := 'parámetros - pcchasis: ' || pcchasis;
      vpasexec       NUMBER(8) := 0;
      v_valida_cchasis NUMBER := 0;
      v_longitud_cchasis NUMBER := 0;
      v_numerror_longitud NUMBER := 9904747;
      v_numerror_formato NUMBER := 9904748;
   BEGIN
      vpasexec := 1;
      -- valida que el chasis no tenga caracteres prohibidos
      v_valida_cchasis := pac_validaciones.f_valida_campo(pac_md_common.f_get_cxtempresa(),
                                                          'CCHASIS', pcchasis);

      IF v_valida_cchasis <> 0 THEN
         RETURN v_numerror_formato;
      END IF;

      vpasexec := 2;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN v_numerror_formato;   --Error validar chasis
   END f_valida_chasis;

   FUNCTION f_valida_rieauto(
      psseguro IN NUMBER,   -- Código identificativo del seguro
      pnriesgo IN NUMBER,   --  Numero De Riesgo
      pcversion IN VARCHAR2,   -- En Este Campo Tiene La Siguiente Estructura:
      -- 5 Primeras Posiciones = Marca Del Auto.
      -- Posición 6-7-8 = Modelo Del Auto.
      -- Posición 9-10-11 = Versión Del Auto.
      pcmodelo IN VARCHAR2,   -- Código Del Modelo Del Auto.( Se Corresponde Con El Campo Autmodelos.Smodelo)
      pcmarca IN VARCHAR2,   -- Los Cinco Primeros Caracteres Del Campo Cversion.
      pctipveh IN VARCHAR2,   -- Código Del Tipo De Vehículo
      pcclaveh IN VARCHAR2,   -- Código De La Clase De Vehiculo.
      pcmatric IN VARCHAR2,   -- Matricula Vehiculo. No Se Informa Si  Ctipmat = 2, Sin Matricula
      pctipmat IN NUMBER,   -- Tipo De Matricula. Tipo De Patente
      pcuso IN VARCHAR2,   -- Codigo Uso Del Vehiculo
      pcsubuso IN VARCHAR2,   -- Codigo Subuso Del Vehiculo
      pfmatric IN DATE,   -- Fecha de primera matriculación
      pnkilometros IN NUMBER,   -- Número de kilómetros anuales. Valor fijo = 295
      pivehicu IN NUMBER,   --  Importe Vehiculo
      pnpma IN NUMBER,   --  Peso Máximo Autorizado
      pntara IN NUMBER,   --  Tara
      pnpuertas IN NUMBER,   --  Numero de puertas del vehiculo
      pnplazas IN NUMBER,   --  Numero de plazas del vehiculo
      pcmotor IN VARCHAR2,   -- Tipo combustible(Tipo de motor (Gasolina, Diesel,etc))
      pcgaraje IN NUMBER,   -- Utiliza garaje. Valor fijo = 296
      pcvehb7 IN NUMBER,   -- Indica si procede de base siete o no. Valor fijo = 108
      pcusorem IN NUMBER,   --Utiliza remolque . Valor fijo =108 ( si o no )
      pcremolque IN NUMBER,   -- Descripción del remolque. Valor fijo =297
      pccolor IN NUMBER,   --  Código color vehículo. Valor fijo = 440
      pcvehnue IN VARCHAR2,   -- Indica si el vehículo es nuevo o no.
      pnbastid IN VARCHAR2,
      pcchasis IN VARCHAR2,   -- Código de chasis
      pcodmotor IN VARCHAR2,   -- Código del motor
      psproduc IN NUMBER,   --Código del producto)
      pfefecto IN DATE,   --Fecha de Efecto
      panyo IN NUMBER)   --Anyo del vehiculo
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 0;
      v_valida_ctipmat NUMBER := 0;
      v_valida_cchasis NUMBER := 0;
      v_valida_nbastid NUMBER := 0;
      v_valida_codmotor NUMBER := 0;
      v_valida_duplicidad NUMBER := 0;
      nerror         NUMBER;
      nerror1        NUMBER;
      nerror2        NUMBER;
      nerror3        NUMBER;
      v_cvalpar      NUMBER;
      vparam         VARCHAR2(4000)
         := 'parámetros - psseguro: ' || psseguro || ' pnriesgo: ' || pnriesgo
            || ' pcversion: ' || pcversion || ' pcmarca: ' || pcmarca || ' pctipveh: '
            || pctipveh || ' pcclaveh: ' || pcclaveh || ' pcmatric: ' || pcmatric
            || ' pctipmat: ' || pctipmat || ' pcuso: ' || pcuso || ' pcsubuso: ' || pcsubuso
            || ' pfmatric: ' || pfmatric || ' pnkilometros: ' || pnkilometros || ' pivehicu: '
            || pivehicu || ' pnpma: ' || pnpma || ' pntara: ' || pntara || ' pnpuertas: '
            || pnpuertas || ' pnplazas: ' || pnplazas || ' pcmotor: ' || pcmotor
            || ' pcgaraje: ' || pcgaraje || ' pcvehb7: ' || pcvehb7 || ' pcusorem: '
            || pcusorem || ' pcremolque: ' || pcremolque || ' pccolor: ' || pccolor
            || ' pcvehnue: ' || pcvehnue || ' pnbastid: ' || pnbastid || ' pcchasis: '
            || pcchasis || ' pcodmotor: ' || pcodmotor || ' psproduc: ' || psproduc || 'anyo:'
            || panyo;
      vobjectname    VARCHAR2(200) := 'PAC_AUTOS.f_valida_rieauto';
   BEGIN
      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'V_ANYO'), 0) = 1 THEN
         IF panyo NOT BETWEEN EXTRACT(YEAR FROM f_sysdate) - 35 AND EXTRACT
                                                                          (YEAR FROM f_sysdate)
                                                                    + 1 THEN
            RETURN 9905775;
         END IF;
      END IF;

      vpasexec := 1;
      -- valida la matrícula
      v_valida_ctipmat := pac_autos.f_valida_ctipmat(pctipmat, pcmatric, pcversion, pctipveh);

      IF v_valida_ctipmat <> 0 THEN
         RETURN v_valida_ctipmat;
      END IF;

      vpasexec := 2;
      -- valida el chasis
      v_valida_cchasis := pac_autos.f_valida_chasis(pcchasis);

      IF v_valida_cchasis <> 0 THEN
         RETURN v_valida_cchasis;
      END IF;

      vpasexec := 3;
      -- valida el vin
      v_valida_nbastid := pac_validaciones.f_valida_campo(pac_md_common.f_get_cxtempresa(),
                                                          'NBASTID', pnbastid);

      IF v_valida_nbastid <> 0 THEN
         IF v_valida_nbastid = 50000 THEN
            --Formato de bastidor incorrecto
            RETURN 9904837;
         ELSE
            RETURN v_valida_nbastid;
         END IF;
      END IF;

      vpasexec := 4;
      -- valida el campo motor
      v_valida_codmotor := pac_validaciones.f_valida_campo(pac_md_common.f_get_cxtempresa(),
                                                           'CODMOTOR', pcodmotor);

      IF v_valida_codmotor <> 0 THEN
         IF v_valida_codmotor = 50000 THEN
            --Formato de motor incorrecto
            RETURN 9904838;
         ELSE
            RETURN v_valida_codmotor;
         END IF;
      END IF;

--      --BUG 0025628: INICIO - DCT - 22/01/2013
--      --Validamos que no haya duplicidad de matrículas, vin o código del motor.
--      IF pac_iax_produccion.issimul = FALSE THEN
--         vpasexec := 5;
--         nerror := f_parproductos(psproduc, 'POLIZA_UNICA', v_cvalpar);

      --         IF nerror <> 0 THEN
--            RETURN nerror;
--         END IF;

      --         IF NVL(v_cvalpar, 0) = 4 THEN   --por cumulo
--            --BUG 26435 - INICIO - DCT - 15/03/2013 - Añadir pcchasis
--            v_valida_duplicidad := f_controlduplicidad(psseguro, pcmatric, pnbastid,
--                                                       pcodmotor, psproduc, pfefecto,
--                                                       pcchasis);

      --            --BUG 26435 - FIN - DCT - 15/03/2013
--            IF v_valida_duplicidad <> 0 THEN
--               RETURN v_valida_duplicidad;
--            END IF;
--         END IF;
--      END IF;
      vpasexec := 6;
      --BUG 0025628: FIN - DCT - 22/01/2013
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9001128;   --Error validar el auto
   END f_valida_rieauto;

   /*************************************************************************
      FUNCTION f_set_version
         Funció que inserta en AUT_VERSIONES
         param in pcmarca   : Codi de la marca
         param in pcmodelo  : Codi del modelo
         param in pctipveh  : Codi tipo vehícle
         param in pcclaveh  : Codi classe vehícle
         param in pcversion : Codi de la versió
         param in ptversion : Descripció versió
         param in ptvarian  : Complement a la versió (en 2ª categoria)
         param in pnpuerta  : Número de portes totals en turismes
         param in pnpuertl  : Número de portes laterals dels furgons
         param in pnpuertt  : Número de portes del darrera dels furgons
         param in pflanzam  : Data del llançament. Format mes/any (mm/aaaa)
         param in pntara    : Pes en buit
         param in pnpma     : Pes Màxim Admès
         param in pnvolcar  : Volum de carga en els furgons
         param in pnlongit  : Longitud del vehícle
         param in pnvia     : Via davantera
         param in pnneumat  : Amplada de pneumàtic davanter
         param in pcvehcha  : Descripció xassis
         param in pcvehlog  : Descripció longitud
         param in pcvehacr  : Descripció tacament
         param in pcvehcaj  : Descripció de caixa
         param in pcvehtec  : Descripció de sostre
         param in pcmotor   : Tipus de motor (Gasolina, Diesel,  Elèctric, etc)
         param in pncilind  : Cilindrada del motor
         param in pnpotecv  : Poténcia del vehícle
         param in pnpotekw  : Poténcia del vehícle
         param in pnplazas  : Número màxim de places
         param in pnace100  : Temps d'acceleració de 0 a 100 Km/h.
         param in pnace400  : Temps d'acceleració de 0 a 400 metres
         param in pnveloc   : Velocitat màxima
         param in pcvehb7   : Indica si ve de base set o no
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_set_version(
      pcmarca IN VARCHAR2,
      pcmodelo IN VARCHAR2,
      pctipveh IN VARCHAR2,
      pcclaveh IN VARCHAR2,
      pcversion IN VARCHAR2,
      ptversion IN VARCHAR2,
      pnpuerta IN NUMBER,
      pflanzam IN DATE,
      pntara IN NUMBER,
      pnpma IN NUMBER,
      pcmotor IN VARCHAR2,
      pncilind IN NUMBER,
      pnpotecv IN NUMBER,
      pnpotekw IN NUMBER,
      pnplazas IN NUMBER,
      pcvehb7 IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_AUTOS.f_set_version';
      vparam         VARCHAR2(500)
         := 'parámetros - pcmarca: ' || pcmarca || ' pcmodelo:' || pcmodelo || ' pctipveh:'
            || pctipveh || ' pcclaveh:' || pcclaveh || ' pcversion:' || pcversion
            || ' ptversion:' || ptversion || ' pnpuerta:' || pnpuerta || ' pflanzam:'
            || pflanzam || ' pntara:' || pntara || ' pnpma:' || pnpma || ' pcmotor:'
            || pcmotor || ' pncilind:' || pncilind || ' pnpotecv:' || pnpotecv || ' pnpotekw:'
            || pnpotekw || ' pnplazas:' || pnplazas || ' pcvehb7:' || pcvehb7;
      vpasexec       NUMBER(5) := 1;
      vseqversion    VARCHAR2(11);
   BEGIN
      IF pcversion IS NULL THEN
         SELECT LPAD(pcmarca, 5, '0') || LPAD(pcmodelo, 3, '0')
                || LPAD(sversion.NEXTVAL, 3, '0')
           INTO vseqversion
           FROM DUAL;
      ELSE
         vseqversion := pcversion;
      END IF;

      BEGIN
         INSERT INTO aut_versiones
                     (cversion, cmodelo, cmarca, cclaveh, ctipveh, tversion,
                      npuerta, flanzam, ntara, npma, cmotor, ncilind, npotecv,
                      npotekw, nplazas, cvehb7)
              VALUES (vseqversion, pcmodelo, pcmarca, pcclaveh, pctipveh, ptversion,
                      pnpuerta, pflanzam, pntara, pnpma, pcmotor, pncilind, pnpotecv,
                      pnpotekw, pnplazas, pcvehb7);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE aut_versiones
               SET cmodelo = pcmodelo,
                   cmarca = pcmarca,
                   cclaveh = pcclaveh,
                   ctipveh = pctipveh,
                   tversion = ptversion,
                   npuerta = pnpuerta,
                   flanzam = pflanzam,
                   ntara = pntara,
                   npma = pnpma,
                   cmotor = pcmotor,
                   ncilind = pncilind,
                   npotecv = pnpotecv,
                   npotekw = pnpotekw,
                   nplazas = pnplazas,
                   cvehb7 = pcvehb7
             WHERE cversion = vseqversion;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9001137;   --Error al insertar la versió (AUT_VERSIONES)
   END f_set_version;

-- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_desversion
   /*************************************************************************
      FUNCTION f_desversion
         Funcion que busca la descripcion de la version de un vehiculo
         param in pcversion : Codi de la versió
         return             : descripcion de la version
   *************************************************************************/
   FUNCTION f_desversion(pcversion IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_tversion     aut_versiones.tversion%TYPE;   -- VARCHAR2(100)
   BEGIN
      SELECT tversion
        INTO v_tversion
        FROM aut_versiones
       WHERE cversion = pcversion;

      RETURN v_tversion;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_autos.f_desversion', 1,
                     'pcversion = ' || pcversion, 'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_desversion;

-- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_desversion

   -- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_desmodelo
   /*************************************************************************
      FUNCTION f_desmodelo
         Funcion que busca la descripcion del modelo de un vehiculo
         param in pcmodelo : Codigo del modelo
         param in pcmarca : Codigo de la marca
         return            : descripcion del modelo
   *************************************************************************/
   FUNCTION f_desmodelo(pcmodelo IN VARCHAR2, pcmarca IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_tmodelo      aut_modelos.tmodelo%TYPE;   -- VARCHAR2(100)
   BEGIN
      SELECT tmodelo
        INTO v_tmodelo
        FROM aut_modelos
       WHERE cmarca = pcmarca
         AND cmodelo = pcmodelo
         AND cempres = pac_md_common.f_get_cxtempresa();

      RETURN v_tmodelo;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_autos.f_desmodelo', 1,
                     'pcmodelo = ' || pcmodelo || '  pcmarca = ' || pcmarca,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_desmodelo;

-- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_desmodelo

   -- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_desmarca
   /*************************************************************************
      FUNCTION f_desmarca
         Funcion que busca la descripcion de la marca de un vehiculo
         param in pcmarca : Codigo de la marca
         return            : descripcion de la marca
   *************************************************************************/
   FUNCTION f_desmarca(pcmarca IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_tmarca       aut_marcas.tmarca%TYPE;   -- VARCHAR2(100)
   BEGIN
      SELECT tmarca
        INTO v_tmarca
        FROM aut_marcas
       WHERE cmarca = pcmarca
         AND cempres = pac_md_common.f_get_cxtempresa();

      RETURN v_tmarca;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_autos.f_desmarca', 1, 'pcmarca = ' || pcmarca,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_desmarca;

-- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_desmarca

   -- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_destipveh
   /*************************************************************************
      FUNCTION f_destipveh
         Funcion que busca la descripcion del tipo de un vehiculo
         param in pctipveh : Codigo del tipo de vehiculo
         param in pcidioma : Idioma de la descripcion
         return            : descripcion del tipo
   *************************************************************************/
   FUNCTION f_destipveh(pctipveh IN VARCHAR2, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      v_ttipveh      aut_destipveh.ttipveh%TYPE;   -- VARCHAR2(100)
   BEGIN
      SELECT ttipveh
        INTO v_ttipveh
        FROM aut_destipveh
       WHERE ctipveh = pctipveh
         AND cempres = pac_md_common.f_get_cxtempresa()
         AND cidioma = pcidioma;

      RETURN v_ttipveh;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_autos.f_destipveh', 1,
                     'pctipveh = ' || pctipveh || '  pcidioma = ' || pcidioma,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_destipveh;

-- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_destipveh

   -- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_desclaveh
   /*************************************************************************
      FUNCTION f_desclaveh
         Funcion que busca la descripcion de la clase de un vehiculo
         param in pcclaveh : Codigo de la clase de vehiculo
         param in pcidioma : Idioma de la descripcion
         return            : descripcion del tipo
   *************************************************************************/
   FUNCTION f_desclaveh(pcclaveh IN VARCHAR2, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      v_tclaveh      aut_desclaveh.tclaveh%TYPE;   -- VARCHAR2(100)
   BEGIN
      SELECT tclaveh
        INTO v_tclaveh
        FROM aut_desclaveh
       WHERE cclaveh = pcclaveh
         AND cempres = pac_md_common.f_get_cxtempresa()
         AND cidioma = pcidioma;

      RETURN v_tclaveh;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_autos.f_desclaveh', 1,
                     'pcclaveh = ' || pcclaveh || '  pcidioma = ' || pcidioma,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_desclaveh;

-- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_desclaveh

   -- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_desuso
   /*************************************************************************
      FUNCTION f_desuso
         Funcion que busca la descripcion del uso de un vehiculo
         param in pcuso : Codigo del uso de vehiculo
         param in pcidioma : Idioma de la descripcion
         return            : descripcion del uso
   *************************************************************************/
   FUNCTION f_desuso(pcuso IN VARCHAR2, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      v_tuso         aut_desuso.tuso%TYPE;   -- VARCHAR2(100)
   BEGIN
      SELECT tuso
        INTO v_tuso
        FROM aut_desuso
       WHERE cuso = pcuso
         AND cidioma = pcidioma
         AND cempres = pac_md_common.f_get_cxtempresa();

      RETURN v_tuso;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_autos.f_desuso', 1,
                     'pcuso = ' || pcuso || '  pcidioma = ' || pcidioma,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_desuso;

-- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_desuso

   -- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_dessubuso
   /*************************************************************************
      FUNCTION f_dessubuso
         Funcion que busca la descripcion del subuso de un vehiculo
         param in pcuso : Codigo del subuso de vehiculo
         param in pcidioma : Idioma de la descripcion
         return            : descripcion del subuso
   *************************************************************************/
   FUNCTION f_dessubuso(pcsubuso IN VARCHAR2, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      v_tsubuso      aut_dessubuso.tsubuso%TYPE;   -- VARCHAR2(100)
   BEGIN
      SELECT tsubuso
        INTO v_tsubuso
        FROM aut_dessubuso
       WHERE csubuso = pcsubuso
         AND cidioma = pcidioma
         AND cempres = pac_md_common.f_get_cxtempresa();

      RETURN v_tsubuso;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_autos.f_dessubuso', 1,
                     'pcsubuso = ' || pcsubuso || '  pcidioma = ' || pcidioma,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_dessubuso;

-- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_dessubuso

   -- BUG 0025412 - FAL - 11/01/2013
   FUNCTION f_get_digitverif_matric(pctipmat IN NUMBER, pcmatric IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_obj          VARCHAR2(100) := 'pac_propio.f_get_digitverif_matric';
      v_param        VARCHAR2(500) := 't=' || pctipmat || '-m=' || pcmatric;
      n_pas          NUMBER;
      v_numero       VARCHAR2(20);
      v_suma         NUMBER;
      v_modulo11     NUMBER;
      v_digito       NUMBER(1);
      v_3carac       VARCHAR2(1);
      v_format_mat   NUMBER;
      v_1y2_carac    VARCHAR2(2);
      v_equival      aut_digitverif_matric.cequival%TYPE;
      v_cmatric      VARCHAR2(7);
      i              NUMBER := 1;
      v_caracter     VARCHAR2(1);
      v_car_equiv    VARCHAR2(1);
   BEGIN
      v_3carac := SUBSTR(pcmatric, 3, 1);

      IF pctipmat = 16 THEN
         IF INSTR('1234567890', v_3carac) = 0 THEN
            RETURN NULL;
         ELSE
            v_1y2_carac := SUBSTR(pcmatric, 1, 2);

            BEGIN
               SELECT cequival
                 INTO v_equival
                 FROM aut_digitverif_matric
                WHERE cserie = v_1y2_carac;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 1;
            END;

            v_cmatric := v_equival || SUBSTR(pcmatric, 3, 4);
            v_suma := SUBSTR(LPAD(v_cmatric, 7, 0), 1, 1) * 2
                      + SUBSTR(LPAD(v_cmatric, 7, 0), 2, 1) * 7
                      + SUBSTR(LPAD(v_cmatric, 7, 0), 3, 1) * 6
                      + SUBSTR(LPAD(v_cmatric, 7, 0), 4, 1) * 5
                      + SUBSTR(LPAD(v_cmatric, 7, 0), 5, 1) * 4
                      + SUBSTR(LPAD(v_cmatric, 7, 0), 6, 1) * 3
                      + SUBSTR(LPAD(v_cmatric, 7, 0), 7, 1) * 2;
            n_pas := 110;
            v_modulo11 := MOD(v_suma, 11);
            n_pas := 111;
            v_digito := 11 - v_modulo11;

            IF v_digito = 11 THEN
               --OK
               RETURN '0';
            ELSIF v_digito = 10 THEN
               RETURN 'K';
            ELSE
               RETURN v_digito;
            END IF;
         END IF;
      ELSIF pctipmat = 17 THEN
         -- IF INSTR('QWERTYUIOPASDFGHJKLZXCVBNM', UPPER(v_3carac)) = 0 THEN
         IF INSTR('QWRTYPSDFGHJKLZXCVBNM', UPPER(v_3carac)) = 0 THEN   -- BUG 26968/0147424 - FAL - 25/06/2013 -- No admite vocales
            RETURN NULL;
         ELSE
            WHILE i <= 4 LOOP
               v_caracter := SUBSTR(pcmatric, i, 1);

               SELECT DECODE(v_caracter,
                             'B', '1',
                             'C', '2',
                             'D', '3',
                             'F', '4',
                             'G', '5',
                             'H', '6',
                             'J', '7',
                             'K', '8',
                             'L', '9',
                             'P', '0',
                             'R', '2',
                             'S', '3',
                             'T', '4',
                             'V', '5',
                             'W', '6',
                             'X', '7',
                             'Y', '8',
                             'Z', '9')
                 INTO v_car_equiv
                 FROM DUAL;

               v_cmatric := v_cmatric || v_car_equiv;
               i := i + 1;
            END LOOP;

            v_cmatric := v_cmatric || SUBSTR(pcmatric, 5, 2);
            v_suma := SUBSTR(LPAD(v_cmatric, 6, 0), 1, 1) * 7
                      + SUBSTR(LPAD(v_cmatric, 6, 0), 2, 1) * 6
                      + SUBSTR(LPAD(v_cmatric, 6, 0), 3, 1) * 5
                      + SUBSTR(LPAD(v_cmatric, 6, 0), 4, 1) * 4
                      + SUBSTR(LPAD(v_cmatric, 6, 0), 5, 1) * 3
                      + SUBSTR(LPAD(v_cmatric, 6, 0), 6, 1) * 2;
            n_pas := 110;
            v_modulo11 := MOD(v_suma, 11);
            n_pas := 111;
            v_digito := 11 - v_modulo11;

            IF v_digito = 11 THEN
               --OK
               RETURN '0';
            ELSIF v_digito = 10 THEN
               RETURN 'K';
            ELSE
               RETURN v_digito;
            END IF;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_obj, n_pas, v_param, SQLCODE || ' ' || SQLERRM);
         RETURN NULL;
   END f_get_digitverif_matric;

-- FI BUG 0025412

   /*************************************************************************
      FUNCTION f_controlduplicidad
          Funcion que valida si la matrícula y/o bastidor y/o código motor no esten duplicados
          param in pcmatric: Codigo de la matrícula
          param in pnbastid : Codigo del bastidor
          param in pcodmotor: Codigo del motor
          param in psproduc:  Codigo del producto
          param in pfefecto:  Fecha efecto
          return: 0(OK) x(error)
    *************************************************************************/
   FUNCTION f_controlduplicidad(
      psseguro IN NUMBER,
      pcmatric IN VARCHAR2,
      pnbastid IN VARCHAR2,
      pcodmotor IN VARCHAR2,
      psproduc IN NUMBER,
      pfefecto IN DATE,
      pcchasis IN VARCHAR2 DEFAULT NULL,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 0;
      nerror         NUMBER := 0;
      nerror1        NUMBER;
      nerror2        NUMBER;
      nerror3        NUMBER;
      nerror4        NUMBER;
      vparam         VARCHAR2(4000)
         := 'parámetros -  psseguro:' || psseguro || ' pcmatric: ' || pcmatric
            || ' pnbastid: ' || pnbastid || ' pcodmotor: ' || pcodmotor || ' psproduc: '
            || psproduc || ' pfefecto: ' || pfefecto || ' pcchasis: ' || pcchasis;
      vobjectname    VARCHAR2(200) := 'PAC_AUTOS.f_controlduplicidad';
   BEGIN
      IF ptablas = 'EST' THEN
         IF pcmatric IS NOT NULL THEN
            SELECT COUNT(1)
              INTO nerror1
              FROM autriesgos r, seguros s
             WHERE r.sseguro = s.sseguro
               AND r.cmatric = pcmatric
               AND(r.sseguro NOT IN(SELECT ssegpol
                                      FROM estseguros
                                     WHERE sseguro = psseguro)
                   OR psseguro IS NULL)
               AND(s.sproduc IN(SELECT cp.cproduc
                                  FROM cum_cumprod cp, cum_cumulo cc
                                 WHERE cc.scumulo = cp.ccumulo
                                   AND cc.cnivel = 0
                                   AND cc.scumulo IN(SELECT scumulo
                                                       FROM cum_cumprod
                                                      WHERE cproduc = psproduc))
                   OR(0 IN(SELECT NVL(creaseg, 0)
                             FROM productos
                            WHERE sproduc = s.sproduc)))
               -- AND r.fanulac IS NULL --que el riesgo no este anulado
                -- BUG 11330 - 15/10/2009 - FAL - Filtrar también que no estén vencidas
                            -- AND s.csituac <> 2 -- que no estén anuladas
                --ini bug 29315#c161490, JDS 18-12-2013
               --AND s.csituac NOT IN(2, 3)   -- que no estén anuladas ni vencidas
               AND(f_vigente(s.sseguro, NULL, pfefecto) = 0
                   OR csituac IN(4, 5)
                   -- Bug 31686/178722 - 04/07/2014 - AMC
                   OR(s.fefecto > pfefecto
                      AND f_vigente(s.sseguro, NULL, s.fefecto) = 0))
               --fi bug 29315#c161490, JDS 18-12-2013
               -- FI BUG 11330 - 15/10/2009 – FAL
               AND NOT(s.csituac = 4
                       AND creteni IN(3, 4))
               -- BUG 11330 - 15/10/2009 - FAL - Filtrar no se cuenten pólizas con vencimiento programado a fecha anterior al efecto de la nueva póliza
               AND((s.fvencim IS NULL)
                   OR(s.fvencim IS NOT NULL
                      AND s.fvencim > pfefecto
                      AND(pac_anulacion.f_esta_prog_anulproxcar(s.sseguro) = 1
                          OR pac_anulacion.f_esta_anulada_vto(s.sseguro) = 1
                          -- BUG 26785 - FAL - 26/04/2013
                          OR(3 = (SELECT cduraci
                                    FROM productos
                                   WHERE sproduc = s.sproduc)
                             AND s.fefecto <= pfefecto   -- BUG 26968/0147424 - FAL - 25/06/2013
                                                      -- FI BUG 26785
                            ))))
               AND((s.fanulac IS NULL)
                   OR(s.fanulac > pfefecto))
               --BUG 28455/156716 - RCL - 28/10/2013 - QT-0009745: Error ál validar matriculas
               AND r.nmovimi = (SELECT MAX(nmovimi)
                                  FROM autriesgos
                                 WHERE autriesgos.sseguro = s.sseguro);
         END IF;

         IF pnbastid IS NOT NULL THEN
            SELECT COUNT(1)
              INTO nerror2
              FROM autriesgos r, seguros s
             WHERE r.sseguro = s.sseguro
               AND r.nbastid = pnbastid
               AND(r.sseguro NOT IN(SELECT ssegpol
                                      FROM estseguros
                                     WHERE sseguro = psseguro)
                   OR psseguro IS NULL)
               AND(s.sproduc IN(SELECT cp.cproduc
                                  FROM cum_cumprod cp, cum_cumulo cc
                                 WHERE cc.scumulo = cp.ccumulo
                                   AND cc.cnivel = 0
                                   AND cc.scumulo IN(SELECT scumulo
                                                       FROM cum_cumprod
                                                      WHERE cproduc = psproduc))
                   OR(0 IN(SELECT NVL(creaseg, 0)
                             FROM productos
                            WHERE sproduc = s.sproduc)))
                 -- AND r.fanulac IS NULL --que el riesgo no este anulado
                  -- BUG 11330 - 15/10/2009 - FAL - Filtrar también que no estén vencidas
                              -- AND s.csituac <> 2 -- que no estén anuladas
               --  AND s.csituac NOT IN(2, 3)   -- que no estén anuladas ni vencidas
               AND(f_vigente(s.sseguro, NULL, pfefecto) = 0
                   OR csituac IN(4, 5)
                   -- Bug 31686/178722 - 04/07/2014 - AMC
                   OR(s.fefecto > pfefecto
                      AND f_vigente(s.sseguro, NULL, s.fefecto) = 0))
               -- FI BUG 11330 - 15/10/2009 – FAL
               AND NOT(s.csituac = 4
                       AND creteni IN(3, 4))
               -- BUG 11330 - 15/10/2009 - FAL - Filtrar no se cuenten pólizas con vencimiento programado a fecha anterior al efecto de la nueva póliza
               AND((s.fvencim IS NULL)
                   OR(s.fvencim IS NOT NULL
                      AND s.fvencim > pfefecto
                      AND(pac_anulacion.f_esta_prog_anulproxcar(s.sseguro) = 1
                          OR pac_anulacion.f_esta_anulada_vto(s.sseguro) = 1)))
               AND((s.fanulac IS NULL)
                   OR(s.fanulac > pfefecto))
               --BUG 28455/156716 - RCL - 28/10/2013 - QT-0009745: Error ál validar matriculas
               AND r.nmovimi = (SELECT MAX(nmovimi)
                                  FROM autriesgos
                                 WHERE autriesgos.sseguro = s.sseguro);
         END IF;

         IF pcodmotor IS NOT NULL THEN
            SELECT COUNT(1)
              INTO nerror3
              FROM autriesgos r, seguros s
             WHERE r.sseguro = s.sseguro
               AND r.codmotor = pcodmotor
               AND(r.sseguro NOT IN(SELECT ssegpol
                                      FROM estseguros
                                     WHERE sseguro = psseguro)
                   OR psseguro IS NULL)
               AND(s.sproduc IN(SELECT cp.cproduc
                                  FROM cum_cumprod cp, cum_cumulo cc
                                 WHERE cc.scumulo = cp.ccumulo
                                   AND cc.cnivel = 0
                                   AND cc.scumulo IN(SELECT scumulo
                                                       FROM cum_cumprod
                                                      WHERE cproduc = psproduc))
                   OR(0 IN(SELECT NVL(creaseg, 0)
                             FROM productos
                            WHERE sproduc = s.sproduc)))
                -- AND r.fanulac IS NULL --que el riesgo no este anulado
                 -- BUG 11330 - 15/10/2009 - FAL - Filtrar también que no estén vencidas
                             -- AND s.csituac <> 2 -- que no estén anuladas
               -- AND s.csituac NOT IN(2, 3)   -- que no estén anuladas ni vencidas
                -- FI BUG 11330 - 15/10/2009 – FAL
               AND(f_vigente(s.sseguro, NULL, pfefecto) = 0
                   OR csituac IN(4, 5)
                   -- Bug 31686/178722 - 04/07/2014 - AMC
                   OR(s.fefecto > pfefecto
                      AND f_vigente(s.sseguro, NULL, s.fefecto) = 0))
               AND NOT(s.csituac = 4
                       AND creteni IN(3, 4))
               -- BUG 11330 - 15/10/2009 - FAL - Filtrar no se cuenten pólizas con vencimiento programado a fecha anterior al efecto de la nueva póliza
               AND((s.fvencim IS NULL)
                   OR(s.fvencim IS NOT NULL
                      AND s.fvencim > pfefecto
                      AND(pac_anulacion.f_esta_prog_anulproxcar(s.sseguro) = 1
                          OR pac_anulacion.f_esta_anulada_vto(s.sseguro) = 1)))
               AND((s.fanulac IS NULL)
                   OR(s.fanulac > pfefecto))
               --BUG 28455/156716 - RCL - 28/10/2013 - QT-0009745: Error ál validar matriculas
               AND r.nmovimi = (SELECT MAX(nmovimi)
                                  FROM autriesgos
                                 WHERE autriesgos.sseguro = s.sseguro);
         END IF;

         --BUG 26435 - INICIO - DCT - 15/03/2013
         IF pcchasis IS NOT NULL THEN
            SELECT COUNT(1)
              INTO nerror4
              FROM autriesgos r, seguros s
             WHERE r.sseguro = s.sseguro
               AND r.cchasis = pcchasis
               AND(r.sseguro NOT IN(SELECT ssegpol
                                      FROM estseguros
                                     WHERE sseguro = psseguro)
                   OR psseguro IS NULL)
               AND(s.sproduc IN(SELECT cp.cproduc
                                  FROM cum_cumprod cp, cum_cumulo cc
                                 WHERE cc.scumulo = cp.ccumulo
                                   AND cc.cnivel = 0
                                   AND cc.scumulo IN(SELECT scumulo
                                                       FROM cum_cumprod
                                                      WHERE cproduc = psproduc))
                   OR(0 IN(SELECT NVL(creaseg, 0)
                             FROM productos
                            WHERE sproduc = s.sproduc)))
                 -- AND r.fanulac IS NULL --que el riesgo no este anulado
                  -- BUG 11330 - 15/10/2009 - FAL - Filtrar también que no estén vencidas
                              -- AND s.csituac <> 2 -- que no estén anuladas
               --  AND s.csituac NOT IN(2, 3)   -- que no estén anuladas ni vencidas
               AND(f_vigente(s.sseguro, NULL, pfefecto) = 0
                   OR csituac IN(4, 5)
                   -- Bug 31686/178722 - 04/07/2014 - AMC
                   OR(s.fefecto > pfefecto
                      AND f_vigente(s.sseguro, NULL, s.fefecto) = 0))
               -- FI BUG 11330 - 15/10/2009 – FAL
               AND NOT(s.csituac = 4
                       AND creteni IN(3, 4))
               -- BUG 11330 - 15/10/2009 - FAL - Filtrar no se cuenten pólizas con vencimiento programado a fecha anterior al efecto de la nueva póliza
               AND((s.fvencim IS NULL)
                   OR(s.fvencim IS NOT NULL
                      AND s.fvencim > pfefecto
                      AND(pac_anulacion.f_esta_prog_anulproxcar(s.sseguro) = 1
                          OR pac_anulacion.f_esta_anulada_vto(s.sseguro) = 1)))
               AND((s.fanulac IS NULL)
                   OR(s.fanulac > pfefecto))
               --BUG 28455/156716 - RCL - 28/10/2013 - QT-0009745: Error ál validar matriculas
               AND r.nmovimi = (SELECT MAX(nmovimi)
                                  FROM autriesgos
                                 WHERE autriesgos.sseguro = s.sseguro);
         END IF;
      --BUG 26435 - FIN - DCT - 15/03/2013
      ELSE
         IF pcmatric IS NOT NULL THEN
            SELECT COUNT(1)
              INTO nerror1
              FROM autriesgos r, seguros s
             WHERE r.sseguro = s.sseguro
               AND r.cmatric = pcmatric
               AND(r.sseguro NOT IN(SELECT sseguro
                                      FROM seguros
                                     WHERE sseguro = psseguro)
                   OR psseguro IS NULL)
               AND(s.sproduc IN(SELECT cp.cproduc
                                  FROM cum_cumprod cp, cum_cumulo cc
                                 WHERE cc.scumulo = cp.ccumulo
                                   AND cc.cnivel = 0
                                   AND cc.scumulo IN(SELECT scumulo
                                                       FROM cum_cumprod
                                                      WHERE cproduc = psproduc))
                   OR(0 IN(SELECT NVL(creaseg, 0)
                             FROM productos
                            WHERE sproduc = s.sproduc)))
                -- AND r.fanulac IS NULL --que el riesgo no este anulado
                 -- BUG 11330 - 15/10/2009 - FAL - Filtrar también que no estén vencidas
                             -- AND s.csituac <> 2 -- que no estén anuladas
               -- AND s.csituac NOT IN(2, 3)   -- que no estén anuladas ni vencidas
               AND(f_vigente(s.sseguro, NULL, pfefecto) = 0
                   OR csituac IN(4, 5)
                   -- Bug 31686/178722 - 04/07/2014 - AMC
                   OR(s.fefecto > pfefecto
                      AND f_vigente(s.sseguro, NULL, s.fefecto) = 0))
               -- FI BUG 11330 - 15/10/2009 – FAL
               AND NOT(s.csituac = 4
                       AND creteni IN(3, 4))
               -- BUG 11330 - 15/10/2009 - FAL - Filtrar no se cuenten pólizas con vencimiento programado a fecha anterior al efecto de la nueva póliza
               AND((s.fvencim IS NULL)
                   OR(s.fvencim IS NOT NULL
                      AND s.fvencim > pfefecto
                      AND(pac_anulacion.f_esta_prog_anulproxcar(s.sseguro) = 1
                          OR pac_anulacion.f_esta_anulada_vto(s.sseguro) = 1
                          -- BUG 26785 - FAL - 26/04/2013
                          OR(3 = (SELECT cduraci
                                    FROM productos
                                   WHERE sproduc = s.sproduc)
                             AND s.fefecto <= pfefecto   -- BUG 26968/0147424 - FAL - 25/06/2013
                                                      -- FI BUG 26785
                            ))))
               AND((s.fanulac IS NULL)
                   OR(s.fanulac > pfefecto))
               --BUG 28455/156716 - RCL - 28/10/2013 - QT-0009745: Error ál validar matriculas
               AND r.nmovimi = (SELECT MAX(nmovimi)
                                  FROM autriesgos
                                 WHERE autriesgos.sseguro = s.sseguro);
         END IF;

         IF pnbastid IS NOT NULL THEN
            SELECT COUNT(1)
              INTO nerror2
              FROM autriesgos r, seguros s
             WHERE r.sseguro = s.sseguro
               AND r.nbastid = pnbastid
               AND(r.sseguro NOT IN(SELECT sseguro
                                      FROM seguros
                                     WHERE sseguro = psseguro)
                   OR psseguro IS NULL)
               AND(s.sproduc IN(SELECT cp.cproduc
                                  FROM cum_cumprod cp, cum_cumulo cc
                                 WHERE cc.scumulo = cp.ccumulo
                                   AND cc.cnivel = 0
                                   AND cc.scumulo IN(SELECT scumulo
                                                       FROM cum_cumprod
                                                      WHERE cproduc = psproduc))
                   OR(0 IN(SELECT NVL(creaseg, 0)
                             FROM productos
                            WHERE sproduc = s.sproduc)))
                -- AND r.fanulac IS NULL --que el riesgo no este anulado
                 -- BUG 11330 - 15/10/2009 - FAL - Filtrar también que no estén vencidas
                             -- AND s.csituac <> 2 -- que no estén anuladas
               -- AND s.csituac NOT IN(2, 3)   -- que no estén anuladas ni vencidas
               AND(f_vigente(s.sseguro, NULL, pfefecto) = 0
                   OR csituac IN(4, 5)
                   -- Bug 31686/178722 - 04/07/2014 - AMC
                   OR(s.fefecto > pfefecto
                      AND f_vigente(s.sseguro, NULL, s.fefecto) = 0))
               -- FI BUG 11330 - 15/10/2009 – FAL
               AND NOT(s.csituac = 4
                       AND creteni IN(3, 4))
               -- BUG 11330 - 15/10/2009 - FAL - Filtrar no se cuenten pólizas con vencimiento programado a fecha anterior al efecto de la nueva póliza
               AND((s.fvencim IS NULL)
                   OR(s.fvencim IS NOT NULL
                      AND s.fvencim > pfefecto
                      AND(pac_anulacion.f_esta_prog_anulproxcar(s.sseguro) = 1
                          OR pac_anulacion.f_esta_anulada_vto(s.sseguro) = 1)))
               AND((s.fanulac IS NULL)
                   OR(s.fanulac > pfefecto))
               --BUG 28455/156716 - RCL - 28/10/2013 - QT-0009745: Error ál validar matriculas
               AND r.nmovimi = (SELECT MAX(nmovimi)
                                  FROM autriesgos
                                 WHERE autriesgos.sseguro = s.sseguro);
         END IF;

         IF pcodmotor IS NOT NULL THEN
            SELECT COUNT(1)
              INTO nerror3
              FROM autriesgos r, seguros s
             WHERE r.sseguro = s.sseguro
               AND r.codmotor = pcodmotor
               AND(r.sseguro NOT IN(SELECT sseguro
                                      FROM seguros
                                     WHERE sseguro = psseguro)
                   OR psseguro IS NULL)
               AND(s.sproduc IN(SELECT cp.cproduc
                                  FROM cum_cumprod cp, cum_cumulo cc
                                 WHERE cc.scumulo = cp.ccumulo
                                   AND cc.cnivel = 0
                                   AND cc.scumulo IN(SELECT scumulo
                                                       FROM cum_cumprod
                                                      WHERE cproduc = psproduc))
                   OR(0 IN(SELECT NVL(creaseg, 0)
                             FROM productos
                            WHERE sproduc = s.sproduc)))
               -- AND r.fanulac IS NULL --que el riesgo no este anulado
                -- BUG 11330 - 15/10/2009 - FAL - Filtrar también que no estén vencidas
                            -- AND s.csituac <> 2 -- que no estén anuladas
               --AND s.csituac NOT IN(2, 3)   -- que no estén anuladas ni vencidas
               AND(f_vigente(s.sseguro, NULL, pfefecto) = 0
                   OR csituac IN(4, 5)
                   -- Bug 31686/178722 - 04/07/2014 - AMC
                   OR(s.fefecto > pfefecto
                      AND f_vigente(s.sseguro, NULL, s.fefecto) = 0))
               -- FI BUG 11330 - 15/10/2009 – FAL
               AND NOT(s.csituac = 4
                       AND creteni IN(3, 4))
               -- BUG 11330 - 15/10/2009 - FAL - Filtrar no se cuenten pólizas con vencimiento programado a fecha anterior al efecto de la nueva póliza
               AND((s.fvencim IS NULL)
                   OR(s.fvencim IS NOT NULL
                      AND s.fvencim > pfefecto
                      AND(pac_anulacion.f_esta_prog_anulproxcar(s.sseguro) = 1
                          OR pac_anulacion.f_esta_anulada_vto(s.sseguro) = 1)))
               AND((s.fanulac IS NULL)
                   OR(s.fanulac > pfefecto))
               --BUG 28455/156716 - RCL - 28/10/2013 - QT-0009745: Error ál validar matriculas
               AND r.nmovimi = (SELECT MAX(nmovimi)
                                  FROM autriesgos
                                 WHERE autriesgos.sseguro = s.sseguro);
         END IF;

         --BUG 26435 - INICIO - DCT - 15/03/2013
         IF pcchasis IS NOT NULL THEN
            SELECT COUNT(1)
              INTO nerror4
              FROM autriesgos r, seguros s
             WHERE r.sseguro = s.sseguro
               AND r.cchasis = pcchasis
               AND(r.sseguro NOT IN(SELECT sseguro
                                      FROM seguros
                                     WHERE sseguro = psseguro)
                   OR psseguro IS NULL)
               AND(s.sproduc IN(SELECT cp.cproduc
                                  FROM cum_cumprod cp, cum_cumulo cc
                                 WHERE cc.scumulo = cp.ccumulo
                                   AND cc.cnivel = 0
                                   AND cc.scumulo IN(SELECT scumulo
                                                       FROM cum_cumprod
                                                      WHERE cproduc = psproduc))
                   OR(0 IN(SELECT NVL(creaseg, 0)
                             FROM productos
                            WHERE sproduc = s.sproduc)))
                -- AND r.fanulac IS NULL --que el riesgo no este anulado
                 -- BUG 11330 - 15/10/2009 - FAL - Filtrar también que no estén vencidas
                             -- AND s.csituac <> 2 -- que no estén anuladas
               -- AND s.csituac NOT IN(2, 3)   -- que no estén anuladas ni vencidas
               AND(f_vigente(s.sseguro, NULL, pfefecto) = 0
                   OR csituac IN(4, 5)
                   -- Bug 31686/178722 - 04/07/2014 - AMC
                   OR(s.fefecto > pfefecto
                      AND f_vigente(s.sseguro, NULL, s.fefecto) = 0))
               -- FI BUG 11330 - 15/10/2009 – FAL
               AND NOT(s.csituac = 4
                       AND creteni IN(3, 4))
               -- BUG 11330 - 15/10/2009 - FAL - Filtrar no se cuenten pólizas con vencimiento programado a fecha anterior al efecto de la nueva póliza
               AND((s.fvencim IS NULL)
                   OR(s.fvencim IS NOT NULL
                      AND s.fvencim > pfefecto
                      AND(pac_anulacion.f_esta_prog_anulproxcar(s.sseguro) = 1
                          OR pac_anulacion.f_esta_anulada_vto(s.sseguro) = 1)))
               AND((s.fanulac IS NULL)
                   OR(s.fanulac > pfefecto))
               --BUG 28455/156716 - RCL - 28/10/2013 - QT-0009745: Error ál validar matriculas
               AND r.nmovimi = (SELECT MAX(nmovimi)
                                  FROM autriesgos
                                 WHERE autriesgos.sseguro = s.sseguro);
         END IF;
      END IF;

      --Si encontramos alguna póliza significa que estas duplicando la matrícula, vin o código del motor
      IF nerror1 > 0 THEN
         nerror := 9904839;   --Matrícula ya existente
      ELSIF nerror2 > 0 THEN
         nerror := 9904841;   --Bastidor ya existente
      ELSIF nerror3 > 0 THEN
         nerror := 9904842;   --Código del motor ya existente
      ELSIF nerror4 > 0 THEN
         nerror := 9905114;   --Código del chasis ya existente
      END IF;

      RETURN nerror;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN nerror;   --Error validar el auto
   END f_controlduplicidad;

    -- BUG 0025202 -  ECP  - 15/02/2013
   /*************************************************************************
      FUNCTION f_despeso
         Funcion que busca la descripcion del peso de un vehiculo
         param in pcpeso : Codigo del peso
         return            : descripcion del peso
   *************************************************************************/
   FUNCTION f_despeso(psproduc IN NUMBER, pcpeso IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      v_tpeso        aut_prod_pesos.tpeso%TYPE;
   BEGIN
      BEGIN
         SELECT tpeso
           INTO v_tpeso
           FROM aut_prod_pesos
          WHERE sproduc = psproduc
            AND cpeso = pcpeso
            AND cidioma = pcidioma;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT tpeso
              INTO v_tpeso
              FROM aut_prod_pesos
             WHERE sproduc = 0
               AND cpeso = pcpeso
               AND cidioma = pcidioma;
      END;

      RETURN v_tpeso;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_autos.f_despeso', 1, 'pcpeso = ' || pcpeso,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_despeso;

    /*************************************************************************
      FUNCTION f_get_valorauto
         Funcion que busca el valor de una version
         param in psseguro : Codigo del seguro
         param in pnriesgo : Numero de riesgo
         param in psproces : Codigo del proceso
         param in pcversion : Código de la versión
         param out pvalorcomercial : valor comercial
         param out pvalorcomercial_nuevo : nuevo valor comercial
         return  0 - Ok 1 Ko

         Bug 26638/160933 - 11/12/2013 - AMC
   *************************************************************************/
   FUNCTION f_get_valorauto(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      psproces IN NUMBER,
      pcversion IN VARCHAR2,
      pdonde IN NUMBER,
      pvalorcomercial OUT NUMBER,
      pvalorcomercial_nuevo OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      IF pdonde = 1 THEN
         SELECT (SELECT vcomercial
                   FROM aut_versiones_anyo aut
                  WHERE aut.cversion = av.cversionhomologo
                    AND aut.anyo = ar.anyo),
                (SELECT vcomercial
                   FROM aut_versiones_anyo aut
                  WHERE aut.cversion = av.cversionhomologo
                    AND aut.anyo = (SELECT MAX(anyo)
                                      FROM aut_versiones_anyo d
                                     WHERE d.cversion = av.cversionhomologo))
           INTO pvalorcomercial,
                pvalorcomercial_nuevo
           FROM aut_versiones_anyo d, aut_versiones av, autriesgoscar ar
          WHERE d.cversion = pcversion
            AND av.cversion = d.cversion
            AND ar.anyo = d.anyo
            AND ar.sseguro = psseguro
            AND ar.nriesgo = pnriesgo
            AND av.cversion = ar.cversion
            AND ar.sproces = psproces;
      ELSE
         SELECT vcomercial,
                (SELECT vcomercial
                   FROM aut_versiones_anyo d
                  WHERE d.cversion = pcversion
                    AND anyo = (SELECT MAX(anyo)
                                  FROM aut_versiones_anyo d
                                 WHERE d.cversion = pcversion))
           INTO pvalorcomercial,
                pvalorcomercial_nuevo
           FROM aut_versiones_anyo d, aut_versiones av, estautriesgos ar, estseguros es
          WHERE d.cversion = pcversion
            AND av.cversion = d.cversion
            AND ar.anyo = d.anyo
            AND ar.sseguro = psseguro
            AND ar.sseguro = es.sseguro
            AND ar.nriesgo = pnriesgo;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pvalorcomercial := NULL;
         pvalorcomercial_nuevo := NULL;
         RETURN 0;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_autos.f_get_valorauto', 1,
                     'psseguro = ' || psseguro || ' pnriesgo:' || pnriesgo || ' psproces:'
                     || psproces || ' pcversion:' || pcversion,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END;
END pac_autos;

/

  GRANT EXECUTE ON "AXIS"."PAC_AUTOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_AUTOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_AUTOS" TO "PROGRAMADORESCSI";
