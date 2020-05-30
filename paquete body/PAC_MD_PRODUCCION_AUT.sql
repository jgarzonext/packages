--------------------------------------------------------
--  DDL for Package Body PAC_MD_PRODUCCION_AUT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_PRODUCCION_AUT" IS
/******************************************************************************
   NOMBRE:       PAC_MD_PRODUCCION_AUT
   PROPÓSITO: Funcions per gestionar autos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        03/03/2009   XVM                1. Creación del package.
   2.0        04/10/2010   JTS                2. 16163: CRT - Modificar tabla descripcion riesgo (autriesgo)
   3.0        13/02/2013   JTS                3. 0025859: LCOL_T031-LCOL - AUT - Pantalla conductores (axisctr061) Id 428
   4.0        14/02/2013   JDS                4. 0025964: LCOL - AUT - Experiencia
   5.0        26/03/2013   ECP                5. 0025202: LCOL_T031 - Adaptar pantalla riesgo - autos. Id 428
   6.0        21/03/2013   ECP                5. 0025943: LCOL_T031-LCOL - AUTOS CONTINUIDAD
   7.0        21/08/2013   JSV                7. 0027953: LCOL - Autos Garantias por Modalidad
   8.0        10/12/2013   JDS                8. 0029315: LCOL_T031-Revisi?n Q-Trackers Fase 3A III
   9.0        12/12/2013   JSV                9. 0029315: LCOL_T031-Revisi?n Q-Trackers Fase 3A III
   10.0       08/01/2014   JDS                10. 0029315: LCOL_T031-Revisi?n Q-Trackers Fase 3A III
   11.0       14/01/2014   JDS                11. 0029659: LCOL_T031-Migración autos
   12.0       18/02/2014   RCL                12. 0029315: LCOL_T031-Revisi?n Q-Trackers Fase 3A III
   13.0       19/03/2014   JDS                13. 0030256: LCOL_T032-Modificar modelo autos a?adiendo : CPESO, CTRANSMISION, NPUERTAS
  14.0       13/06/2014   SSM                14. 0031803/0177317: LCOL895-Interfaz Cexper - Tiempo respuesta interfaz
  15.0       04/11/2014    ECP                15. 0033221/0014488: Placa ya creada - completar informacion de accesorio y dispositivo
 ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      FUNCTION f_get_caccesorio
         Funció que retorna un nou codi d'accesori
         param in  paccesorio  : col·lecció d'accesoris
         param out pcacc       : codi accesori
         param in out mensajes : col·lecció de missatges
         return                : 0 -> Tot correcte
                                 1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_get_caccesorio(
      paccesorio IN t_iax_autaccesorios,
      pcacc OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - null:';
      vobject        VARCHAR2(200) := 'PAC_MD_PRODUCCION_AUT.f_get_caccesorio';
      errores        t_ob_error;
      vnumerr        NUMBER(8) := 0;
      vcont_acc      NUMBER(5);
   BEGIN
      IF paccesorio IS NULL THEN
         RAISE e_param_error;
      END IF;

      vcont_acc := paccesorio.COUNT;
      pcacc := 'NOGEN' || LPAD(TO_CHAR(vcont_acc), 5, '0');
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_caccesorio;

   /*************************************************************************
      FUNCTION f_set_version
         Funció que valida i inserta en AUT_VERSIONES
         param in pcmarca      : Codi de la marca
         param in pcmodelo     : Codi del modelo
         param in pctipveh     : Codi tipo vehícle
         param in pcclaveh     : Codi classe vehícle
         param in pcversion    : Codi de la versió
         param in ptversion    : Descripció versió
         param in ptvarian     : Complement a la versió (en 2ª categoria)
         param in pnpuerta     : Número de portes totals en turismes
         param in pnpuertl     : Número de portes laterals dels furgons
         param in pnpuertt     : Número de portes del darrera dels furgons
         param in pflanzam     : Data del llançament. Format mes/any (mm/aaaa)
         param in pntara       : Pes en buit
         param in pnpma        : Pes Màxim Admès
         param in pnvolcar     : Volum de carga en els furgons
         param in pnlongit     : Longitud del vehícle
         param in pnvia        : Via davantera
         param in pnneumat     : Amplada de pneumàtic davanter
         param in pcvehcha     : Descripció xassis
         param in pcvehlog     : Descripció longitud
         param in pcvehacr     : Descripció tacament
         param in pcvehcaj     : Descripció de caixa
         param in pcvehtec     : Descripció de sostre
         param in pcmotor      : Tipus de motor (Gasolina, Diesel,  Elèctric, etc)
         param in pncilind     : Cilindrada del motor
         param in pnpotecv     : Poténcia del vehícle
         param in pnpotekw     : Poténcia del vehícle
         param in pnplazas     : Número màxim de places
         param in pnace100     : Temps d'acceleració de 0 a 100 Km/h.
         param in pnace400     : Temps d'acceleració de 0 a 400 metres
         param in pnveloc      : Velocitat màxima
         param in pcvehb7      : Indica si ve de base set o no
         param in out mensajes : col·lecció de missatges
         return                : 0 -> Tot correcte
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
      pcvehb7 IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - pcmarca: ' || pcmarca || ' pcmodelo:' || pcmodelo || ' pctipveh:'
            || pctipveh || ' pcclaveh:' || pcclaveh || ' pcversion:' || pcversion
            || ' ptversion:' || ptversion || ' pnpuerta:' || pnpuerta || ' pflanzam:'
            || pflanzam || ' pntara:' || pntara || ' pnpma:' || pnpma || ' pcmotor:'
            || pcmotor || ' pncilind:' || pncilind || ' pnpotecv:' || pnpotecv || ' pnpotekw:'
            || pnpotekw || ' pnplazas:' || pnplazas || ' pcvehb7:' || pcvehb7;
      vobject        VARCHAR2(200) := 'PAC_MD_PRODUCCION_AUT.f_set_version';
      errores        t_ob_error;
      vnumerr        NUMBER(8) := 0;
      vcont_acc      NUMBER(5);
   BEGIN
      vnumerr := pac_autos.f_valida_version(pcmarca, pcmodelo, pctipveh, pcclaveh, pcversion,
                                            ptversion, pnpuerta, pflanzam, pntara, pnpma,
                                            pcmotor, pncilind, pnpotecv, pnpotekw, pnplazas,
                                            pcvehb7);
      vpasexec := 2;

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      vnumerr := pac_autos.f_set_version(pcmarca, pcmodelo, pctipveh, pcclaveh, pcversion,
                                         ptversion, pnpuerta, pflanzam, pntara, pnpma, pcmotor,
                                         pncilind, pnpotecv, pnpotekw, pnplazas, pcvehb7);
      vpasexec := 4;

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_version;

   -- Bug 9247 - APD - 09/03/2009 -- Se crea la funcion f_set_riesauto
   /*************************************************************************
      FUNCTION f_set_riesauto
         Función que carga el objeto de memoria con los cambios que se realizan en pantalla para el objeto de tipo auto.
         param in  psseguro : Código identificativo del seguro
         param in  pnriesgo : Numero De Riesgo
         param in  pcversion : En Este Campo Tiene La Siguiente Estructura:
         param in  pcmodelo : Código Del Modelo Del Auto.( Se Corresponde Con El Campo Autmodelos.Smodelo)
         param in  pcmarca : Los Cinco Primeros Caracteres Del Campo Cversion.
         param in  pctipveh : Código Del Tipo De Vehículo
         param in  pcclaveh : Código De La Clase De Vehiculo.
         param in  pcmatric : Matricula Vehiculo. No Se Informa Si  Ctipmat = 2, Sin Matricula
         param in  pctipmat : Tipo De Matricula. Tipo De Patente
         param in  pcuso : Codigo Uso Del Vehiculo
         param in  pcsubuso : Codigo Subuso Del Vehiculo
         param in  pfmatric : Fecha de primera matriculación
         param in  pnkilometros : Número de kilómetros anuales. Valor fijo = 295
         param in  pivehicu : Importe Vehiculo
         param in  pnpma : Peso Máximo Autorizado
         param in  pntara : Tara
         param in  pnpuertas : Numero de puertas del vehiculo
         param in  pnplazas : Numero de plazas del vehiculo
         param in  pcmotor : Código del motor
         param in  pcgaraje : Utiliza garaje. Valor fijo = 296
         param in  pcvehb7 : Indica si procede de base siete o no. Valor fijo = 108
         param in  pcusorem : Utiliza remolque . Valor fijo =108 ( si o no )
         param in  pcremolque : Descripción del remolque. Valor fijo =297
         param in  pccolor : Código color vehículo. Valor fijo = 440
         param in  pcvehnue : Indica si el vehículo es nuevo o no.
         param in  pnbastid : Número de bastido( chasis)
         param out  pnriesgo_out : Numero De Riesgo calculado
         param out mensajes : col·lecció de missatges
         param in  pcpeso : Peso del vehiculo
         param in  pctransmision : Transmision del vehiculo
         return             : 0 -> Si todo OK
                              1 -> Si ha habido un error
   *************************************************************************/
   FUNCTION f_set_riesauto(
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
      pcmotor IN NUMBER,   -- Código del motor
      pcgaraje IN NUMBER,   -- Utiliza garaje. Valor fijo = 296
      pcvehb7 IN NUMBER,   -- Indica si procede de base siete o no. Valor fijo = 108
      pcusorem IN NUMBER,   --Utiliza remolque . Valor fijo =108 ( si o no )
      pcremolque IN NUMBER,   -- Descripción del remolque. Valor fijo =297
      pccolor IN NUMBER,   --  Código color vehículo. Valor fijo = 440
      pcvehnue IN NUMBER,   -- Indica si el vehículo es nuevo o no.
      pnbastid IN VARCHAR2,   -- Número de bastido( chasis)
      ptriesgo IN VARCHAR2,
      pcpaisorigen IN NUMBER,
      pcodmotor IN VARCHAR2,
      pcchasis IN VARCHAR2,
      pivehinue IN NUMBER,
      pnkilometraje IN NUMBER,
      pccilindraje IN VARCHAR2,
      pcpintura IN NUMBER,
      pccaja IN NUMBER,
      pccampero IN NUMBER,
      pctipcarroceria IN NUMBER,
      pcservicio IN NUMBER,
      pcorigen IN NUMBER,
      pctransporte IN NUMBER,
      pivehicufasecolda IN NUMBER,
      pivehicufasecoldanue IN NUMBER,
      panyo IN NUMBER,
      pnriesgo_out IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes,
      pffinciant IN DATE DEFAULT NULL,
      pciaant IN NUMBER DEFAULT NULL,
      pcpeso IN NUMBER DEFAULT NULL,
      pctransmision IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      nerr           NUMBER;
      vpasexec       NUMBER := 1;
      vparam         CLOB
         := 'parámetros -     psseguro      ' || psseguro || '   pnriesgo     ' || pnriesgo
            || '   pcversion    ' || pcversion || '   pcmarca     ' || pcmarca
            || '   pctipveh      ' || pctipveh || '   pcclaveh     ' || pcclaveh
            || '   pcmatric     ' || pcmatric || '   pctipmat     ' || pctipmat
            || '   pcuso        ' || pcuso || '   pcsubuso        ' || pcsubuso
            || '   pfmatric     ' || pfmatric || '   pnkilometros ' || pnkilometros
            || '   pivehicu           ' || pivehicu || '   pnpma           ' || pnpma
            || '   pntara       ' || pntara || '   pnpuertas       ' || pnpuertas
            || '   pnplazas   ' || pnplazas || '   pcmotor         ' || pcmotor
            || '   pcgaraje     ' || pcgaraje || '   pcvehb7         ' || pcvehb7
            || '   pcusorem     ' || pcusorem || '   pcremolque      ' || pcremolque
            || '   pccolor   ' || pccolor || '   pcvehnue        ' || pcvehnue
            || '   pnbastid    ' || pnbastid || '   ptriesgo        ' || ptriesgo
            || '   pffinciant  ' || pffinciant || '   pciaant         ' || pciaant
            || '   pcpeso  ' || pcpeso || '   pctransmision         ' || pctransmision;
      vobject        CLOB := 'PAC_MD_PRODUCCION_AUT.f_set_riesauto';
      vnriesgo       NUMBER;
      vefectsuple    DATE := NULL;
      nerrfefec      NUMBER;
      v_posicion     NUMBER;
      vobdetpoliza   ob_iax_detpoliza;
      vobriesgo      ob_iax_riesgos;
      autrie         ob_iax_autriesgos;
--      autries        t_iax_autriesgos;
--      rie            ob_iax_riesgos;
      ries           t_iax_riesgos;
      v_alta_riesgo  NUMBER;
      vcversion      CLOB;
      vflanzam       DATE;
      vtriesgo       CLOB;
      -- Bug 32705/189453-16/10/2014-AMC
      vheredar       NUMBER := 0;
      vsseguro       NUMBER;
      vres4010       NUMBER;
      vplan          NUMBER;
      vffinciant     DATE := pffinciant;
      vciaant        NUMBER := pciaant;
   -- Fi Bug 32705/189453-16/10/2014-AMC
   BEGIN
      -- Se obtiene el objeto detpoliza
      vobdetpoliza := pac_iobj_prod.f_getpoliza(mensajes);

      IF mensajes IS NOT NULL THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      vpasexec := 1;
      -- Se obtiene la coleccion de riesgos
      ries := pac_iobj_prod.f_partpolriesgos(vobdetpoliza, mensajes);

      -- Si no hay ningun riesgo dado de alta, devuelve al coleccion vacia inicializada
      IF mensajes IS NOT NULL THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      vpasexec := 2;

      IF ries.COUNT > 0 THEN   -- hay riesgos en la coleccion
         -- Se obtiene el objeto riesgo
         vobriesgo := pac_iobj_prod.f_partpolriesgo(vobdetpoliza, pnriesgo, mensajes);

         IF mensajes IS NOT NULL THEN
            vpasexec := 4;
            RAISE e_object_error;
         END IF;

         vpasexec := 3;

         IF vobriesgo.nriesgo IS NOT NULL THEN   -- objeto riesgo ya existente
            -- Se modifica un riesgo/autriesgo
            v_alta_riesgo := 0;   -- NO
            vnriesgo := vobriesgo.nriesgo;
         ELSE   -- no existe el objeto riesgo
            -- Se da de alta un riesgo
            v_alta_riesgo := 1;   -- SI
         END IF;
      ELSE   -- no hay riesgos en la coleccion
         -- Se da de alta un riesgo
         v_alta_riesgo := 1;   -- SI
      END IF;

      vpasexec := 4;

      IF NVL(f_parproductos_v(vobdetpoliza.sproduc, 'VERSION_COMODIN'), 0) = 1 THEN
         IF pcversion IS NULL
            AND pcmarca IS NOT NULL
            AND pcmodelo IS NOT NULL
            AND pctipveh IS NOT NULL THEN
            BEGIN
               SELECT cversion
                 INTO vcversion
                 FROM aut_versiones
                WHERE cmarca = pcmarca
                  AND cmodelo = pcmodelo
                  AND ctipveh = pctipveh
                  AND ccomodin = 1
                  AND cempres = pac_md_common.f_get_cxtempresa;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vcversion := '';
            END;
         END IF;
      END IF;

      -- Se dá de alta un riesgo
      IF v_alta_riesgo = 1
         AND(ries IS NULL
             OR ries.COUNT = 0) THEN   -- SI
         -- si es suplement ha de controlar data efecte
         IF pac_iax_produccion.issuplem THEN
            nerrfefec := pac_md_suplementos.f_get_fefecto_supl(vobdetpoliza.sseguro,
                                                               vobdetpoliza.nmovimi,
                                                               vefectsuple, mensajes);

            IF (nerrfefec <> 0) THEN
               pac_iobj_mensajes.crea_nuevo_mensaje
                                          (mensajes, 1, 9000827,
                                           'No se ha podido recuperar fecha efecto del riesgo');
               RAISE e_object_error;
            END IF;
         END IF;

         vpasexec := 5;
         vnriesgo := ries.COUNT + 1;
         ries.EXTEND;
         ries(ries.LAST) := ob_iax_riesgos();
         ries(ries.LAST).nriesgo := vnriesgo;
         ries(ries.LAST).fefecto := NVL(vefectsuple, vobdetpoliza.gestion.fefecto);   --ACC 13122008 controlar data suple
         ries(ries.LAST).nmovima := vobdetpoliza.nmovimi;
         vpasexec := 6;
         -- ACC 17122008 ha de marcar només el risc ho fa al final ries(ries.last).P_Set_needTarifar(1); -- t.7817
         ries(ries.LAST).triesgo := pcmatric || ' - ' || pac_autos.f_desmarca(pcmarca) || ' - '
                                    || pac_autos.f_desmodelo(pcmodelo, pcmarca) || ' - '
                                    || pac_autos.f_desversion(NVL(pcversion, vcversion));
      ELSE
         vobriesgo.triesgo := pcmatric || ' - ' || pac_autos.f_desmarca(pcmarca) || ' - '
                              || pac_autos.f_desmodelo(pcmodelo, pcmarca) || ' - '
                              || pac_autos.f_desversion(NVL(pcversion, vcversion));
         vnriesgo := 1;
      END IF;

      -- Se obtiene el objeto autriesgo
      autrie := pac_iobj_prod.f_partriesautomovil(vobdetpoliza, pnriesgo, mensajes);
      vpasexec := 7;

      -- Si el autriesgo no exsite devuelve el objeto vacío inicializado, sino
      -- devuelve el objteo autriesgo que queremos modificar
      IF mensajes IS NOT NULL THEN
         vpasexec := 4;
         RAISE e_object_error;
      END IF;

      vpasexec := 8;
      autrie.nriesgo := vnriesgo;
      autrie.cversion := NVL(pcversion, vcversion);
      autrie.tversion := pac_autos.f_desversion(NVL(pcversion, vcversion));
      autrie.cmodelo := pcmodelo;
      vpasexec := 9;
      autrie.tmodelo := pac_autos.f_desmodelo(pcmodelo, pcmarca);
      autrie.cmarca := pcmarca;
      autrie.tmarca := pac_autos.f_desmarca(pcmarca);
      autrie.ctipveh := pctipveh;
      autrie.ttipveh := pac_autos.f_destipveh(pctipveh, gidioma);
      autrie.cclaveh := pcclaveh;
      vpasexec := 10;

      IF pcclaveh IS NOT NULL THEN
         autrie.tclaveh := pac_autos.f_desclaveh(pcclaveh, gidioma);
      END IF;

      autrie.cmatric := pcmatric;
      autrie.ctipmat := pctipmat;
      autrie.ttipmat := ff_desvalorfijo(290, gidioma, pctipmat);
      autrie.cuso := pcuso;
      vpasexec := 11;

      IF pcuso IS NOT NULL THEN
         autrie.tuso := pac_autos.f_desuso(pcuso, gidioma);
      END IF;

      autrie.csubuso := pcsubuso;

      IF pcsubuso IS NOT NULL THEN
         autrie.tsubuso := pac_autos.f_dessubuso(pcsubuso, gidioma);
      END IF;

      autrie.fmatric := pfmatric;
      autrie.nkilometros := pnkilometros;

      IF pnkilometros IS NOT NULL THEN
         autrie.tkilometros := ff_desvalorfijo(295, gidioma, pnkilometros);
      END IF;

      vpasexec := 12;
      autrie.ivehicu := pivehicu;
      autrie.npma := pnpma;
      autrie.ntara := pntara;
      -- Bug 25202 --ECP-- 18/02/2013
      --BUG 30256/166723 - 21/02/2014 - RCL
      autrie.cpeso := pcpeso;   -- Peso
      autrie.tpeso := pac_autos.f_despeso(vobdetpoliza.sproduc, pcpeso, gidioma);
      autrie.npuertas := pnpuertas;
      autrie.nplazas := pnplazas;
      autrie.cmotor := pcmotor;
      autrie.ctransmision := pctransmision;
      vpasexec := 13;

      IF pcmotor IS NOT NULL THEN
         autrie.tmotor := ff_desvalorfijo(291, gidioma, pcmotor);
      END IF;

      autrie.cgaraje := pcgaraje;

      IF pcgaraje IS NOT NULL THEN
         autrie.tgaraje := ff_desvalorfijo(296, gidioma, pcgaraje);
      END IF;

      vpasexec := 14;
      autrie.cvehb7 := pcvehb7;
      autrie.cusorem := pcusorem;
      autrie.cremolque := pcremolque;

      IF pcremolque IS NOT NULL THEN
         autrie.tremdesc := ff_desvalorfijo(297, gidioma, pcremolque);
      END IF;

      autrie.ccolor := pccolor;
      vpasexec := 15;

      IF pccolor IS NOT NULL THEN
         autrie.tcolor := ff_desvalorfijo(440, gidioma, pccolor);
      END IF;

      vpasexec := 151;
      autrie.cvehnue := pcvehnue;
      autrie.nbastid := pnbastid;
      autrie.cpaisorigen := pcpaisorigen;
      vpasexec := 152;

      IF pcpaisorigen IS NOT NULL THEN
         autrie.tpaisorigen := ff_despais(pcpaisorigen, pac_md_common.f_get_cxtidioma());
      END IF;

      vpasexec := 152;
      autrie.codmotor := pcodmotor;
      vpasexec := 1521;
      autrie.cchasis := pcchasis;
      autrie.ivehinue := pivehinue;
      vpasexec := 1522;
      autrie.nkilometraje := pnkilometraje;
      vpasexec := 1523;
      autrie.ccilindraje := pccilindraje;
      vpasexec := 1524;
      autrie.cpintura := pcpintura;
      vpasexec := 153;

      IF pcpintura IS NOT NULL THEN
         autrie.tpintura := ff_desvalorfijo(760, pac_md_common.f_get_cxtidioma, pcpintura);
      END IF;

      vpasexec := 154;
      autrie.ccaja := pccaja;

      IF pccaja IS NOT NULL THEN
         autrie.tcaja := ff_desvalorfijo(8000907, pac_md_common.f_get_cxtidioma, pccaja);
      END IF;

      vpasexec := 155;
      autrie.ccampero := pccampero;

      IF pccampero IS NOT NULL THEN
         autrie.tcampero := ff_desvalorfijo(758, pac_md_common.f_get_cxtidioma, pccampero);
      END IF;

      vpasexec := 156;
      autrie.ctipcarroceria := pctipcarroceria;

      IF pctipcarroceria IS NOT NULL THEN
         autrie.ttipcarroceria := ff_desvalorfijo(761, pac_md_common.f_get_cxtidioma,
                                                  pctipcarroceria);
      END IF;

      vpasexec := 157;
      autrie.cservicio := pcservicio;

      IF pcservicio IS NOT NULL THEN
         autrie.tservicio := ff_desvalorfijo(8000904, pac_md_common.f_get_cxtidioma,
                                             pcservicio);
      END IF;

      vpasexec := 158;
      autrie.corigen := pcorigen;

      IF pcorigen IS NOT NULL THEN
         autrie.torigen := ff_desvalorfijo(8000905, pac_md_common.f_get_cxtidioma, pcorigen);
      END IF;

      vpasexec := 159;
      autrie.ctransporte := pctransporte;

      IF pctransporte IS NOT NULL THEN
         autrie.ttransporte := ff_desvalorfijo(307, pac_md_common.f_get_cxtidioma,
                                               pctransporte);
      END IF;

      vpasexec := 160;
      autrie.ivehicufasecolda := pivehicufasecolda;
      autrie.ivehicufasecoldanue := pivehicufasecoldanue;
      autrie.anyo := panyo;
      autrie.ttara := '';   --todo
      vpasexec := 16;

      IF pcmatric IS NOT NULL THEN
         vtriesgo := pcmatric || ' - ';
      END IF;

      IF pac_autos.f_desmarca(pcmarca) IS NOT NULL THEN
         vtriesgo := vtriesgo || pac_autos.f_desmarca(pcmarca) || ' - ';
      END IF;

      IF pac_autos.f_desmodelo(pcmodelo, pcmarca) IS NOT NULL THEN
         vtriesgo := vtriesgo || pac_autos.f_desmodelo(pcmodelo, pcmarca) || ' - ';
      END IF;

      IF pac_autos.f_desversion(NVL(pcversion, vcversion)) IS NOT NULL THEN
         vtriesgo := vtriesgo || pac_autos.f_desversion(NVL(pcversion, vcversion));
      END IF;

      autrie.triesgo := vtriesgo;
      vpasexec := 161;

      IF NVL(f_parproductos_v(vobdetpoliza.sproduc, 'AUT_COMP_ANTERIOR'), 0) = 1 THEN
         -- Bug 32705/189453-16/10/2014-AMC
         IF NVL(f_parproductos_v(pac_iax_produccion.poliza.det_poliza.sproduc,
                                 'ADMITE_CERTIFICADOS'),
                0) = 1 THEN
            SELECT sseguro
              INTO vsseguro
              FROM seguros
             WHERE npoliza = pac_iax_produccion.poliza.det_poliza.npoliza
               AND ncertif = 0;

            vpasexec := 162;

            IF pac_iax_produccion.poliza.det_poliza.preguntas IS NOT NULL THEN
               IF pac_iax_produccion.poliza.det_poliza.preguntas.COUNT > 0 THEN
                  FOR i IN
                     pac_iax_produccion.poliza.det_poliza.preguntas.FIRST .. pac_iax_produccion.poliza.det_poliza.preguntas.LAST LOOP
                     IF pac_iax_produccion.poliza.det_poliza.preguntas(i).cpregun = 4089 THEN
                        vplan := pac_iax_produccion.poliza.det_poliza.preguntas(i).crespue;
                     END IF;
                  END LOOP;
               END IF;
            END IF;

            vpasexec := 163;

            SELECT crespue
              INTO vres4010
              FROM pregunseg
             WHERE sseguro = vsseguro
               AND nriesgo = NVL(vplan, nriesgo)
               AND cpregun = 4010
               AND nmovimi = (SELECT MAX(nmovimi)
                                FROM garanseg
                               WHERE sseguro = vsseguro
                                 AND ffinefe IS NULL);

            vpasexec := 164;

            IF vres4010 = 1 THEN
               vheredar := 1;

               IF pac_iax_produccion.poliza.det_poliza.riesgos IS NOT NULL THEN
                  IF pac_iax_produccion.poliza.det_poliza.riesgos.COUNT > 0 THEN
                     nerr := pac_iax_produccion.f_grabarpreguntasriesgo(vnriesgo, 4010, 1,
                                                                        NULL, mensajes);
                  END IF;
               END IF;
            ELSE
               IF pac_iax_produccion.poliza.det_poliza.riesgos IS NOT NULL THEN
                  IF pac_iax_produccion.poliza.det_poliza.riesgos.COUNT > 0 THEN
                     nerr := pac_iax_produccion.f_grabarpreguntasriesgo(vnriesgo, 4060, NULL,
                                                                        NULL, mensajes);
                     nerr := pac_iax_produccion.f_grabarpreguntasriesgo(vnriesgo, 4013, NULL,
                                                                        NULL, mensajes);
                     nerr := pac_iax_produccion.f_grabarpreguntasriesgo(vnriesgo, 4010, 0,
                                                                        NULL, mensajes);
                  END IF;
               END IF;
            END IF;
         END IF;

         IF vheredar = 0 THEN
            --Inici BUG 29315 - RCL - 06/02/2014
            IF ((autrie.ffinciant IS NULL
                 AND vffinciant IS NOT NULL)
                OR(autrie.ffinciant IS NOT NULL
                   AND autrie.ffinciant <> vffinciant))
               OR((autrie.ciaant IS NULL
                   AND vciaant IS NOT NULL)
                  OR(autrie.ciaant IS NOT NULL
                     AND autrie.ciaant <> vciaant)) THEN
               --Fi BUG 29315 - RCL - 06/02/2014

               --modifiquem preguntes i calculem continuidad ja s'ha modificat la matricula
               nerr := pac_iax_produccion.f_grabarpreguntasriesgo(vnriesgo, 4060, vciaant,
                                                                  NULL, mensajes);

               IF nerr > 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 151096,
                                                       'Error al insertar el riesgo');
                  RETURN 1;
               END IF;

               nerr := pac_iax_produccion.f_grabarpreguntasriesgo(vnriesgo, 4013, NULL,
                                                                  TO_CHAR(vffinciant,
                                                                          'DD/MM/YYYY'),
                                                                  mensajes);

               IF nerr > 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 151096,
                                                       'Error al insertar el riesgo');
                  RETURN 1;
               END IF;

               IF autrie.anyo IS NOT NULL
                  AND(TO_NUMBER(TO_CHAR(f_sysdate, 'YYYY')) - autrie.anyo <= 5)
                  AND pac_iax_produccion.poliza.det_poliza.gestion.fefecto = pffinciant THEN
                  nerr := pac_iax_produccion.f_grabarpreguntasriesgo(vnriesgo, 4010, 1, NULL,
                                                                     mensajes);

                  IF nerr > 0 THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 151096,
                                                          'Error al insertar el riesgo');
                     RETURN 1;
                  END IF;
               ELSE
                  nerr := pac_iax_produccion.f_grabarpreguntasriesgo(vnriesgo, 4010, 0, NULL,
                                                                     mensajes);

                  IF nerr > 0 THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 151096,
                                                          'Error al insertar el riesgo');
                     RETURN 1;
                  END IF;
               END IF;
            END IF;
         END IF;
      -- Bug 32705/189453-16/10/2014-AMC
      END IF;

      autrie.ffinciant := pffinciant;
      autrie.ciaant := pciaant;
      pac_iax_produccion.poliza.det_poliza.p_set_needtarificar(1);
      vpasexec := 17;

      IF v_alta_riesgo = 1 THEN   -- si se da de alta el objeto riesgo y el objeto autriesgo
         nerr := pac_iobj_prod.f_set_partriesautomovil(pac_iax_produccion.poliza.det_poliza,
                                                       vnriesgo, ries(ries.LAST), autrie,
                                                       mensajes);
      ELSE   -- se modifica el objeto autriesgo
         nerr := pac_iobj_prod.f_set_partriesautomovil(pac_iax_produccion.poliza.det_poliza,
                                                       vnriesgo, vobriesgo, autrie, mensajes);
      END IF;

      vpasexec := 18;

      IF nerr > 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 151096,
                                              'Error al insertar el riesgo');
         RETURN 1;
      END IF;

      vpasexec := 19;
      pnriesgo_out := vnriesgo;
      vpasexec := 20;
      RETURN 0;
-----------------------
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_riesauto;

-- Bug 9247 - APD - 09/03/2009 -- Se crea la funcion f_set_riesauto

   -- Bug 9247 - APD - 09/03/2009 -- Se crea la funcion f_set_conductor
   /*************************************************************************
      FUNCTION f_set_conductor
         Función que carga el objeto de memoria con los cambios que se realizan en pantalla.
         param in  pnriesgo : número riesgo
         param in  pnorden : Numero orden de conductor. El número 1 se corresponde al conductor principal
         param in  psperson : Código de persona (conductor identificado, nominal)
         param in  pfnacimi : Edad conductor innominado
         param in  pnpuntos : Número de puntos en el permiso
         param in  pfcarnet : Fecha de expedición del permiso de conducción
         param in  pcsexo : Sexo conductor innominado
         param in  pexper_manual : Numero de años de experiencia del conductor.
         param in  pexper_cexper : Numero de años de experiencia que viene por interfaz.
         param out mensajes : col·lecció de missatges
         return             : 0 -> Si todo OK
                              1 -> Si ha habido un error

         -- Bug 25368/133447 - 08/01/2013 - AMC  Se añade el pcdomici
         -- Bug 25368/135191 - 15/01/2013 - AMC  Se añade el pcprincipal
   *************************************************************************/
   FUNCTION f_set_conductor(
      pnriesgo IN NUMBER,
      pnorden IN NUMBER,
      psperson IN NUMBER,
      pfnacimi IN DATE,
      pnpuntos IN NUMBER,
      pfcarnet IN DATE,
      pcsexo IN NUMBER,
      pcdomici IN NUMBER,
      pcprincipal IN NUMBER,
      pexper_manual IN NUMBER,
      pexper_cexper IN NUMBER,
      pexper_sinie IN NUMBER,
      pexper_sinie_manual IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'parámetros - pnriesgo: ' || pnriesgo || ' pnorden:' || pnorden || ' psperson:'
            || psperson || ' fnacimi:' || pfnacimi || ' pnpuntos:' || pnpuntos || ' pfcarnet:'
            || pfcarnet || ' pcsexo:' || pcsexo || ' pcdomici:' || pcdomici || ' pcprincipal:'
            || pcprincipal || ' pexper_manual:' || pexper_manual || ' pexper_cexper:'
            || pexper_cexper;
      vobject        VARCHAR2(200) := 'PAC_MD_PRODUCCION_AUT.f_set_conductor';
      errores        t_ob_error;
      vobdetpoliza   ob_iax_detpoliza;
      vobauto        ob_iax_autriesgos;
      vtobconduc     t_iax_autconductores;
      vobpersona     ob_iax_personas;
      vnorden_ult    NUMBER;   -- valor de norden del ultimo conductor existente
      nerr           NUMBER;
      vcompani       NUMBER;
      vinterf        NUMBER;
      vsperson_old   NUMBER;   --BUG 29315/166429 - 18/02/2014 - RCL - El sistema trae anos cexper de cliente anterior
   BEGIN
      -- Se obtiene el objeto detpoliza
      vobdetpoliza := pac_iobj_prod.f_getpoliza(mensajes);

      IF vobdetpoliza IS NULL THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      -- Se obtiene el objeto autriesgo
      vobauto := pac_iobj_prod.f_partriesautomovil(vobdetpoliza, NVL(pnriesgo, 1), mensajes);

      IF vobauto IS NULL THEN
         vpasexec := 3;
         RAISE e_object_error;
      END IF;

      -- Se obtiene la coleccion autconductores
      -- Si la coleccion está vacía la inicializa
      vtobconduc := pac_iobj_prod.f_partautconductores(vobauto, mensajes);

      IF vtobconduc IS NULL THEN
         vpasexec := 4;
         RAISE e_object_error;
      END IF;

      --validamos que la persona no sea jurídica
      IF psperson IS NOT NULL THEN   -- Se obtiene los datos de la persona
         vobpersona := pac_md_persona.f_get_persona(psperson, NULL, mensajes, 'EST');

         IF vobpersona.ctipper = 2 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001313);
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 5;

      IF vtobconduc.COUNT > 0 THEN   -- Existe registros en la coleecion
         -- Para el riesgo de entrada se introducen los datos en memoria con los valores de los parametros de entrada
         FOR vcon IN vtobconduc.FIRST .. vtobconduc.LAST LOOP
            IF vtobconduc.EXISTS(vcon) THEN
               IF vtobconduc(vcon).norden = pnorden THEN
                  --BUG 29315/166429 - 18/02/2014 - RCL - El sistema trae anos cexper de cliente anterior (guardamos el sperson anterior)
                  vsperson_old := vtobconduc(vcon).sperson;
                  vtobconduc(vcon).nriesgo := NVL(pnriesgo, 1);
                  vtobconduc(vcon).norden := pnorden;
                  vtobconduc(vcon).sperson := psperson;
                  vtobconduc(vcon).fnacimi := pfnacimi;
                  vtobconduc(vcon).npuntos := pnpuntos;
                  vtobconduc(vcon).fcarnet := pfcarnet;
                  vtobconduc(vcon).csexo := pcsexo;
                  vtobconduc(vcon).tsexo := ff_desvalorfijo(11, gidioma, pcsexo);
                  vtobconduc(vcon).cdomici := pcdomici;   -- Bug 25368/133447 - 08/01/2013 - AMC
                  vtobconduc(vcon).cprincipal := pcprincipal;   -- Bug 25368/135191 - 15/01/2013 - AMC

                  -- bug 32009/ QT 13652. solo machamos la información si se ha cambiado el conductor o por el motivo que sea el exper de interfaz es nulo.
                  -- Desde simulaciones el campo pexper_cexper siempre llega  anulo.
                  -- Desde Nueva producción llega informado
                  IF vsperson_old <> psperson
                     OR vtobconduc(vcon).exper_cexper IS NULL THEN   --svj
                     vtobconduc(vcon).exper_cexper := pexper_cexper;
                     vtobconduc(vcon).exper_sinie := pexper_sinie;
                  END IF;

                  IF pexper_sinie_manual IS NOT NULL THEN   ---bug 31686#c181829, jds 19/08/2014,
                     vtobconduc(vcon).exper_sinie_manual := pexper_sinie_manual;
                  END IF;

                  IF pexper_manual IS NOT NULL THEN   ---bug 31686#c181829, jds 19/08/2014,
                     vtobconduc(vcon).exper_manual := pexper_manual;
                  END IF;

                  IF psperson IS NOT NULL THEN   -- Se obtiene los datos de la persona
                     vobpersona := pac_md_persona.f_get_persona(psperson, NULL, mensajes,
                                                                'EST');

                     IF vobpersona IS NULL THEN
                        RAISE e_object_error;
                     END IF;

                     vtobconduc(vcon).persona := vobpersona;

                     -- bug 32009/ QT 13652.
                     IF NVL(vsperson_old, 0) <> psperson
                        OR vtobconduc(vcon).exper_cexper IS NULL THEN
                        IF NVL(f_parproductos_v(vobdetpoliza.sproduc, 'AUT_EXPER'), 0) IN
                                                                                        (1, 2)
                           -- Ini Bug 25493 -- ECP-- 21/03/2013
                           OR(pac_iax_produccion.issimul
                              AND NVL(f_parproductos_v(vobdetpoliza.sproduc, 'AUT_EXPER'), 0) =
                                                                                              2) THEN
                           -- Fin Bug 25493 -- ECP-- 21/03/2013
                           nerr :=
                              pac_md_con.f_antiguedadconductor(vobpersona.ctipide,
                                                               vobpersona.nnumide,
                                                               vtobconduc(vcon).exper_cexper,
                                                               vcompani,
                                                               vtobconduc(vcon).exper_sinie,
                                                               vinterf, mensajes);

                           IF nerr <> 0 THEN
                              IF vsperson_old IS NULL
                                 OR vsperson_old <> psperson THEN
                                 vpasexec := 3;
                                 -- Ini Bug 25493 -- ECP-- 21/03/2013
                                 --RAISE e_object_error;
                                 vtobconduc(vcon).exper_cexper := 0;
                                 vcompani := 0;
                                 vtobconduc(vcon).exper_sinie := 0;
                                 vtobconduc(vcon).exper_manual :=
                                                                 vtobconduc(vcon).exper_cexper;
                                 vtobconduc(vcon).exper_sinie_manual :=
                                                                  vtobconduc(vcon).exper_sinie;
                                 mensajes := t_iax_mensajes();
                                 pac_iobj_mensajes.crea_nuevo_mensaje
                                    (mensajes, 2, 9905163,
                                     'La interfaz no ha podido recuperar la información requerida');
                              ELSE
                                 vtobconduc(vcon).exper_cexper := 0;
                                 vcompani := 0;
                                 vtobconduc(vcon).exper_sinie := 0;
                                 vtobconduc(vcon).exper_manual :=
                                                                 vtobconduc(vcon).exper_cexper;
                                 vtobconduc(vcon).exper_sinie_manual :=
                                                                  vtobconduc(vcon).exper_sinie;
                                 mensajes := t_iax_mensajes();
                              END IF;
                           --RETURN 1;
                           ELSE
                              --BUG 29315/166429 - 18/02/2014 - RCL - El sistema trae anos cexper de cliente anterior (Si hay cambio de sperson)
                              IF vsperson_old IS NULL
                                 OR vsperson_old <> psperson
                                 OR vtobconduc(vtobconduc.LAST).exper_manual IS NULL THEN
                                 vtobconduc(vcon).exper_manual :=
                                                                 vtobconduc(vcon).exper_cexper;
                              END IF;

                              IF vsperson_old IS NULL
                                 OR vsperson_old <> psperson
                                 OR vtobconduc(vtobconduc.LAST).exper_sinie_manual IS NULL THEN
                                 vtobconduc(vcon).exper_sinie_manual :=
                                                                  vtobconduc(vcon).exper_sinie;
                              END IF;
                           -- Fin Bug 25493 -- ECP-- 21/03/2013
                           END IF;
                        END IF;
                     END IF;

                     IF pfcarnet IS NULL THEN
                        IF vobpersona.perautcarnets IS NOT NULL
                           AND vobpersona.perautcarnets.COUNT > 0 THEN
                           FOR i IN
                              vobpersona.perautcarnets.FIRST .. vobpersona.perautcarnets.LAST LOOP
                              FOR j IN (SELECT ctipcar
                                          FROM aut_tipoactiprod ata, aut_codtipveh ac,
                                               aut_tipcarnet AT
                                         WHERE ata.sproduc = vobdetpoliza.sproduc
                                           AND ata.cactivi = vobdetpoliza.gestion.cactivi
                                           AND ata.ctipveh = ac.ctipveh
                                           AND AT.ncatego = ac.ncatego) LOOP
                                 IF j.ctipcar = vobpersona.perautcarnets(i).ctipcar THEN
                                    vtobconduc(vcon).fcarnet :=
                                                           vobpersona.perautcarnets(i).fcarnet;
                                 END IF;
                              END LOOP;

                              IF vtobconduc(vcon).fcarnet IS NULL THEN
                                 IF NVL(vobpersona.perautcarnets(i).cdefecto, 0) = 1 THEN
                                    vtobconduc(vcon).fcarnet :=
                                                           vobpersona.perautcarnets(i).fcarnet;
                                 END IF;
                              END IF;
                           END LOOP;
                        END IF;
                     END IF;
                  END IF;

                  nerr :=
                     pac_iobj_prod.f_set_partautconductores
                                                         (pac_iax_produccion.poliza.det_poliza,
                                                          NVL(pnriesgo, 1),
                                                          vtobconduc(vcon).norden,
                                                          vtobconduc(vcon), mensajes);
                  vpasexec := 6;

                  IF nerr > 0 THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001470,
                                                          'Error al guardar el conductor');
                     RETURN 1;
                  END IF;

                  --Bug 25368 - XVM - 25/01/2013.Inicio
                  FOR vcon IN vtobconduc.FIRST .. vtobconduc.LAST LOOP
                     IF vtobconduc.EXISTS(vcon) THEN
                        IF vtobconduc(vcon).cprincipal <> pcprincipal THEN
                           IF vtobconduc(vcon).sperson = psperson THEN
                              pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904859);
                              RETURN 1;
                           END IF;
                        END IF;
                     END IF;
                  END LOOP;

                  --Bug 25368 - XVM - 25/01/2013.Fin
                  RETURN 0;   -- Todo Ok
               ELSE
                  --Bug 25368 - XVM - 25/01/2013. Inicio
                  FOR vcon IN vtobconduc.FIRST .. vtobconduc.LAST LOOP
                     IF vtobconduc.EXISTS(vcon) THEN
                        IF vtobconduc(vcon).sperson = psperson
                           AND vtobconduc(vcon).norden <> pnorden THEN
                           IF vtobconduc(vcon).cprincipal = 1 THEN
                              pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904859);
                              RETURN 1;
                           ELSE
                              pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904905);
                              RETURN 1;
                           END IF;
                        END IF;
                     END IF;
                  END LOOP;

                  --Bug 25368 - XVM - 25/01/2013.Fin
                  vnorden_ult := vtobconduc(vcon).norden;
               END IF;
            END IF;
         END LOOP;

         FOR vcon IN vtobconduc.FIRST .. vtobconduc.LAST LOOP
            IF vtobconduc.EXISTS(vcon) THEN
               IF vtobconduc(vcon).sperson = psperson THEN
                  IF vtobconduc(vcon).cprincipal = 1 THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904859);
                     RETURN 1;
                  ELSE
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904905);
                     RETURN 1;
                  END IF;
               END IF;
            END IF;
         END LOOP;

         vpasexec := 7;
         -- No se está modificando un registro, sino dandolo de alta en la coleccion ya existente
         vtobconduc.EXTEND;
         --BUG 29315/166429 - 18/02/2014 - RCL - El sistema trae anos cexper de cliente anterior (guardamos el sperson anterior)
         vsperson_old := vtobconduc(vtobconduc.LAST).sperson;
         vtobconduc(vtobconduc.LAST) := ob_iax_autconductores();
         vtobconduc(vtobconduc.LAST).nriesgo := NVL(pnriesgo, 1);
         vtobconduc(vtobconduc.LAST).norden := NVL(pnorden, vnorden_ult + 1);
         vtobconduc(vtobconduc.LAST).sperson := psperson;
         vtobconduc(vtobconduc.LAST).fnacimi := pfnacimi;
         vtobconduc(vtobconduc.LAST).npuntos := pnpuntos;
         vtobconduc(vtobconduc.LAST).fcarnet := pfcarnet;
         vtobconduc(vtobconduc.LAST).csexo := pcsexo;
         vtobconduc(vtobconduc.LAST).tsexo := ff_desvalorfijo(11, gidioma, pcsexo);
         vtobconduc(vtobconduc.LAST).cdomici := pcdomici;   -- Bug 25368/133447 - 08/01/2013 - AMC
         vtobconduc(vtobconduc.LAST).cprincipal := pcprincipal;   -- Bug 25368/135191 - 15/01/2013 - AMC
         vtobconduc(vtobconduc.LAST).exper_manual := pexper_manual;
         vtobconduc(vtobconduc.LAST).exper_cexper := pexper_cexper;
         vtobconduc(vtobconduc.LAST).exper_sinie := pexper_sinie;
         vtobconduc(vtobconduc.LAST).exper_sinie_manual := pexper_sinie_manual;

         IF psperson IS NOT NULL THEN   -- Se obtiene los datos de la persona, es un conductor nominado
            vobpersona := pac_md_persona.f_get_persona(psperson, NULL, mensajes, 'EST');

            IF vobpersona IS NULL THEN
               RAISE e_object_error;
            END IF;

            vtobconduc(vtobconduc.LAST).persona := vobpersona;

            IF NVL(f_parproductos_v(vobdetpoliza.sproduc, 'AUT_EXPER'), 0) IN(1, 2)
               -- Ini Bug 25493 -- ECP-- 21/03/2013
               OR(pac_iax_produccion.issimul
                  AND NVL(f_parproductos_v(vobdetpoliza.sproduc, 'AUT_EXPER'), 0) = 2) THEN
               -- Fin Bug 25493 -- ECP-- 21/03/2013
               nerr :=
                  pac_md_con.f_antiguedadconductor(vobpersona.ctipide, vobpersona.nnumide,
                                                   vtobconduc(vtobconduc.LAST).exper_cexper,
                                                   vcompani,
                                                   vtobconduc(vtobconduc.LAST).exper_sinie,
                                                   vinterf, mensajes);

               IF nerr <> 0 THEN
                  vpasexec := 3;
                  -- Ini Bug 25493 -- ECP-- 21/03/2013
                     --RAISE e_object_error;
                  vtobconduc(vtobconduc.LAST).exper_cexper := 0;
                  vcompani := 0;
                  vtobconduc(vtobconduc.LAST).exper_sinie := 0;
                  vtobconduc(vtobconduc.LAST).exper_manual :=
                                                      vtobconduc(vtobconduc.LAST).exper_cexper;
                  vtobconduc(vtobconduc.LAST).exper_sinie_manual :=
                                                       vtobconduc(vtobconduc.LAST).exper_sinie;
                  mensajes := t_iax_mensajes();
                  pac_iobj_mensajes.crea_nuevo_mensaje
                                (mensajes, 2, 9905163,
                                 'La interfaz no ha podido recuperar la información requerida');
               -- RETURN 1;
               ELSE
                  --BUG 29315/166429 - 18/02/2014 - RCL - El sistema trae anos cexper de cliente anterior (Si hay cambio de sperson)
                  IF vsperson_old IS NULL
                     OR vsperson_old <> psperson
                     OR vtobconduc(vtobconduc.LAST).exper_manual IS NULL THEN
                     vtobconduc(vtobconduc.LAST).exper_manual :=
                                                      vtobconduc(vtobconduc.LAST).exper_cexper;
                  END IF;

                  IF vsperson_old IS NULL
                     OR vsperson_old <> psperson
                     OR vtobconduc(vtobconduc.LAST).exper_sinie_manual IS NULL THEN
                     vtobconduc(vtobconduc.LAST).exper_sinie_manual :=
                                                       vtobconduc(vtobconduc.LAST).exper_sinie;
                  END IF;
               -- Fin Bug 25493 -- ECP-- 21/03/2013
               END IF;
            END IF;

            IF pfcarnet IS NULL THEN
               IF vobpersona.perautcarnets IS NOT NULL
                  AND vobpersona.perautcarnets.COUNT > 0 THEN
                  FOR i IN vobpersona.perautcarnets.FIRST .. vobpersona.perautcarnets.LAST LOOP
                     FOR j IN (SELECT ctipcar
                                 FROM aut_tipoactiprod ata, aut_codtipveh ac,
                                      aut_tipcarnet AT
                                WHERE ata.sproduc = vobdetpoliza.sproduc
                                  AND ata.cactivi = vobdetpoliza.gestion.cactivi
                                  AND ata.ctipveh = ac.ctipveh
                                  AND AT.ncatego = ac.ncatego) LOOP
                        IF j.ctipcar = vobpersona.perautcarnets(i).ctipcar THEN
                           vtobconduc(vtobconduc.LAST).fcarnet :=
                                                           vobpersona.perautcarnets(i).fcarnet;
                        END IF;
                     END LOOP;

                     IF vtobconduc(vtobconduc.LAST).fcarnet IS NULL THEN
                        IF NVL(vobpersona.perautcarnets(i).cdefecto, 0) = 1 THEN
                           vtobconduc(vtobconduc.LAST).fcarnet :=
                                                           vobpersona.perautcarnets(i).fcarnet;
                        END IF;
                     END IF;
                  END LOOP;
               END IF;
            END IF;
         END IF;

         nerr := pac_iobj_prod.f_set_partautconductores(pac_iax_produccion.poliza.det_poliza,
                                                        NVL(pnriesgo, 1),
                                                        vtobconduc(vtobconduc.LAST).norden,
                                                        vtobconduc(vtobconduc.LAST), mensajes);
         vpasexec := 8;

         IF nerr > 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001470,
                                                 'Error al guardar el conductor');
            RETURN 1;
         END IF;

         RETURN 0;
      ELSE   -- Se dá de alta el primer registro en la coleccion vacía
         vpasexec := 9;
         vtobconduc.EXTEND;
         --BUG 29315/166429 - 18/02/2014 - RCL - El sistema trae anos cexper de cliente anterior (guardamos el sperson anterior)
         vsperson_old := vtobconduc(vtobconduc.LAST).sperson;
         vtobconduc(vtobconduc.LAST) := ob_iax_autconductores();
         vtobconduc(vtobconduc.LAST).nriesgo := NVL(pnriesgo, 1);
         -- si el conductor es habitual el pnorden = 0 y siempre vendrá informado
         -- por lo que si el pnorden es nulo por defecto pondremos el norden = 1
         -- para dar de alta un conductor ocasional
         -- En un principio nunca pasará que el primer conductor que se dé de alta sea un
         -- conductor ocasional, el primer conductor a dar de alta debe ser el conductor
         -- habitual (sino luego los norden que se calculan no serán correctos)
         vtobconduc(vtobconduc.LAST).norden := NVL(pnorden, 1);
         vtobconduc(vtobconduc.LAST).sperson := psperson;
         vtobconduc(vtobconduc.LAST).fnacimi := pfnacimi;
         vtobconduc(vtobconduc.LAST).npuntos := pnpuntos;
         vtobconduc(vtobconduc.LAST).fcarnet := pfcarnet;
         vtobconduc(vtobconduc.LAST).csexo := pcsexo;
         vtobconduc(vtobconduc.LAST).tsexo := ff_desvalorfijo(11, gidioma, pcsexo);
         vtobconduc(vtobconduc.LAST).cdomici := pcdomici;   -- Bug 25368/133447 - 08/01/2013 - AMC
         vtobconduc(vtobconduc.LAST).cprincipal := pcprincipal;   -- Bug 25368/135191 - 15/01/2013 - AMC
         vtobconduc(vtobconduc.LAST).exper_manual := pexper_manual;
         vtobconduc(vtobconduc.LAST).exper_cexper := pexper_cexper;
         vtobconduc(vtobconduc.LAST).exper_sinie := pexper_sinie;
         vtobconduc(vtobconduc.LAST).exper_sinie_manual := pexper_sinie_manual;

         IF psperson IS NOT NULL THEN   -- Se obtiene los datos de la persona, es un conductor nominado
            vobpersona := pac_md_persona.f_get_persona(psperson, NULL, mensajes, 'EST');

            IF vobpersona IS NULL THEN
               RAISE e_object_error;
            END IF;

            vtobconduc(vtobconduc.LAST).persona := vobpersona;

            IF NVL(f_parproductos_v(vobdetpoliza.sproduc, 'AUT_EXPER'), 0) IN(1, 2)
               -- Ini Bug 25493 -- ECP-- 21/03/2013
               OR(pac_iax_produccion.issimul
                  AND NVL(f_parproductos_v(vobdetpoliza.sproduc, 'AUT_EXPER'), 0) = 2) THEN
               -- Fin Bug 25493 -- ECP-- 21/03/2013
               nerr :=
                  pac_md_con.f_antiguedadconductor(vobpersona.ctipide, vobpersona.nnumide,
                                                   vtobconduc(vtobconduc.LAST).exper_cexper,
                                                   vcompani,
                                                   vtobconduc(vtobconduc.LAST).exper_sinie,
                                                   vinterf, mensajes);

               IF nerr <> 0 THEN
                  vpasexec := 3;
                  -- Ini Bug 25493 -- ECP-- 21/03/2013
                  --RAISE e_object_error;
                  vcompani := 0;
                  vtobconduc(vtobconduc.LAST).exper_cexper := 0;
                  vtobconduc(vtobconduc.LAST).exper_sinie := 0;
                  vtobconduc(vtobconduc.LAST).exper_manual :=
                                                      vtobconduc(vtobconduc.LAST).exper_cexper;
                  vtobconduc(vtobconduc.LAST).exper_sinie_manual :=
                                                       vtobconduc(vtobconduc.LAST).exper_sinie;
                  mensajes := t_iax_mensajes();
                  pac_iobj_mensajes.crea_nuevo_mensaje
                                (mensajes, 2, 9905163,
                                 'La interfaz no ha podido recuperar la información requerida');
               -- RETURN 1;
               ELSE
                  --BUG 29315/166429 - 18/02/2014 - RCL - El sistema trae anos cexper de cliente anterior (Si hay cambio de sperson)
                  IF vsperson_old IS NULL
                     OR vsperson_old <> psperson
                     OR vtobconduc(vtobconduc.LAST).exper_manual IS NULL THEN
                     vtobconduc(vtobconduc.LAST).exper_manual :=
                                                      vtobconduc(vtobconduc.LAST).exper_cexper;
                  END IF;

                  IF vsperson_old IS NULL
                     OR vsperson_old <> psperson
                     OR vtobconduc(vtobconduc.LAST).exper_sinie_manual IS NULL THEN
                     vtobconduc(vtobconduc.LAST).exper_sinie_manual :=
                                                       vtobconduc(vtobconduc.LAST).exper_sinie;
                  END IF;
               -- Fin Bug 25493 -- ECP-- 21/03/2013
               END IF;
            END IF;

            IF pfcarnet IS NULL THEN
               IF vobpersona.perautcarnets IS NOT NULL
                  AND vobpersona.perautcarnets.COUNT > 0 THEN
                  FOR i IN vobpersona.perautcarnets.FIRST .. vobpersona.perautcarnets.LAST LOOP
                     FOR j IN (SELECT ctipcar
                                 FROM aut_tipoactiprod ata, aut_codtipveh ac,
                                      aut_tipcarnet AT
                                WHERE ata.sproduc = vobdetpoliza.sproduc
                                  AND ata.cactivi = vobdetpoliza.gestion.cactivi
                                  AND ata.ctipveh = ac.ctipveh
                                  AND AT.ncatego = ac.ncatego) LOOP
                        IF j.ctipcar = vobpersona.perautcarnets(i).ctipcar THEN
                           vtobconduc(vtobconduc.LAST).fcarnet :=
                                                           vobpersona.perautcarnets(i).fcarnet;
                        END IF;
                     END LOOP;

                     IF vtobconduc(vtobconduc.LAST).fcarnet IS NULL THEN
                        IF NVL(vobpersona.perautcarnets(i).cdefecto, 0) = 1 THEN
                           vtobconduc(vtobconduc.LAST).fcarnet :=
                                                           vobpersona.perautcarnets(i).fcarnet;
                        END IF;
                     END IF;
                  END LOOP;
               END IF;
            END IF;
         END IF;

         nerr := pac_iobj_prod.f_set_partautconductores(pac_iax_produccion.poliza.det_poliza,
                                                        NVL(pnriesgo, 1),
                                                        vtobconduc(vtobconduc.LAST).norden,
                                                        vtobconduc(vtobconduc.LAST), mensajes);
         vpasexec := 10;

         IF nerr > 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001470,
                                                 'Error al guardar el conductor');
            RETURN 1;
         END IF;

         RETURN 0;
      END IF;

      vpasexec := 11;
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001463,
                                           'No se ha encontrado el conductor');
      RETURN 1;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_conductor;

-- Bug 9247 - APD - 09/03/2009 -- Se crea la funcion f_set_conductor

   -- Bug 9247 - APD - 06/03/2009 -- Se crea la funcion f_set_AccesoriosNoSerie
   /*************************************************************************
      FUNCTION f_set_AccesoriosNoSerie
         Función que carga el objeto de memoria con los cambios que se realizan en pantalla.
         param in  pnriesgo : número riesgo
         param in  pcversion : número de version
         param in  pcaccesorio : número de accesorio
         param in  ptdescripcion : descripcion del accesorio
         param in  pivalacc : valor del accesorio
         param in  ptipacc : tipo de accesorio
         param out mensajes : col·lecció de missatges
         return             : 0 -> Si todo OK
                              1 -> Si ha habido un error
   *************************************************************************/
   FUNCTION f_set_accesoriosnoserie(
      pnriesgo IN NUMBER,
      pcversion IN VARCHAR2,   --Obligatiro
      pcaccesorio IN VARCHAR2,   -- No obligatorio
      ptdescripcion IN VARCHAR2,
      pivalacc IN NUMBER,
      pctipacc IN NUMBER,
      pcaccesorio_out IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'parámetros - pnriesgo: ' || pnriesgo || ' pcversion:' || pcversion
            || ' pcaccesorio:' || pcaccesorio || ' ptdescripcion:' || ptdescripcion
            || ' pivalacc:' || pivalacc || ' pctipacc:' || pctipacc;
      vobject        VARCHAR2(200) := 'PAC_MD_PRODUCCION_AUT.f_set_AccesoriosNoSerie';
      errores        t_ob_error;
      vobaccesorios  ob_iax_autaccesorios;   --Objeto accesorio
      i              NUMBER(3);
      vobdetpoliza   ob_iax_detpoliza;
      vobauto        ob_iax_autriesgos;
      vtobacc        t_iax_autaccesorios;
      v_existe_acc   NUMBER := 0;   -- NO
      nerr           NUMBER;
   BEGIN
      -- Se obtiene el objeto detpoliza
      vobdetpoliza := pac_iobj_prod.f_getpoliza(mensajes);

      IF mensajes IS NOT NULL THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      -- Se obtiene el objeto autriesgo
      vobauto := pac_iobj_prod.f_partriesautomovil(vobdetpoliza, NVL(pnriesgo, 1), mensajes);

      IF mensajes IS NOT NULL THEN
         vpasexec := 3;
         RAISE e_object_error;
      END IF;

      -- Se obtiene la coleccion autaccesorios
      vtobacc := pac_iobj_prod.f_partautaccesorios(vobauto, mensajes);

      IF mensajes IS NOT NULL THEN
         vpasexec := 4;
         RAISE e_object_error;
      END IF;

      -- Si el campo caccesorio no viene informado, se está dando de alta un nuevo accesorio no serie
      -- El valor del campo caccesorio se debe calcular
      IF pcaccesorio IS NULL THEN
         vtobacc.EXTEND;
         vtobacc(vtobacc.LAST) := ob_iax_autaccesorios();
         vtobacc(vtobacc.LAST).nriesgo := pnriesgo;
         vtobacc(vtobacc.LAST).cversion := pcversion;
         vtobacc(vtobacc.LAST).caccesorio := 'NOGEN' || vtobacc.LAST;
         vtobacc(vtobacc.LAST).ctipacc := pctipacc;
         vtobacc(vtobacc.LAST).ttipacc := ff_desvalorfijo(292, gidioma, pctipacc);
         vtobacc(vtobacc.LAST).fini := f_sysdate;
         vtobacc(vtobacc.LAST).ivalacc := pivalacc;
         vtobacc(vtobacc.LAST).tdesacc := ptdescripcion;
         nerr := pac_iobj_prod.f_set_partautaccesorios(pac_iax_produccion.poliza.det_poliza,
                                                       pnriesgo, vtobacc, mensajes);

         IF nerr > 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001471,
                                                 'Error al guardar el accesorio');
            RETURN 1;
         END IF;

         pcaccesorio_out := vtobacc(vtobacc.LAST).caccesorio;
         RETURN 0;
      ELSE   -- pcaccesorio IS NOT NULL --> se está modificando un accesorio no serie
         FOR vacc IN vtobacc.FIRST .. vtobacc.LAST LOOP
            IF vtobacc.EXISTS(vacc) THEN
               IF vtobacc(vacc).cversion = pcversion
                  AND vtobacc(vacc).caccesorio = pcaccesorio THEN
                  vtobacc(vacc).nriesgo := pnriesgo;
                  vtobacc(vacc).cversion := pcversion;
                  vtobacc(vacc).caccesorio := pcaccesorio;
                  vtobacc(vacc).ctipacc := pctipacc;
                  vtobacc(vacc).ttipacc := ff_desvalorfijo(292, gidioma, pctipacc);
                  vtobacc(vacc).ivalacc := pivalacc;
                  vtobacc(vacc).tdesacc := ptdescripcion;
                  v_existe_acc := 1;   --si
               END IF;
            END IF;
         END LOOP;

         IF v_existe_acc = 0 THEN   -- NO
            vtobacc.EXTEND;
            vtobacc(vtobacc.LAST) := ob_iax_autaccesorios();
            vtobacc(vtobacc.LAST).nriesgo := pnriesgo;
            vtobacc(vtobacc.LAST).cversion := pcversion;
            vtobacc(vtobacc.LAST).caccesorio := pcaccesorio;
            vtobacc(vtobacc.LAST).ctipacc := pctipacc;
            vtobacc(vtobacc.LAST).ttipacc := ff_desvalorfijo(292, gidioma, pctipacc);
            vtobacc(vtobacc.LAST).fini := f_sysdate;
            vtobacc(vtobacc.LAST).ivalacc := pivalacc;
            vtobacc(vtobacc.LAST).tdesacc := ptdescripcion;
         END IF;

         nerr := pac_iobj_prod.f_set_partautaccesorios(pac_iax_produccion.poliza.det_poliza,
                                                       pnriesgo, vtobacc, mensajes);

         IF nerr > 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001471,
                                                 'Error al guardar el accesorio');
            RETURN 1;
         END IF;

         RETURN 0;
      END IF;

      RETURN 1;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_accesoriosnoserie;

-- Bug 9247 - APD - 06/03/2009 -- Fin Se crea la funcion f_set_AccesoriosNoSerie

   -- Bug 9247 - APD - 06/03/2009 -- Se crea la funcion f_set_detautriesgos
   /*************************************************************************
      FUNCTION f_set_detautriesgos
         Función que insertará en objeto ob_iax_autaccesorios del objeto póliza
         param in pnriesgo: numero de riesgo
         param in pnmovimi: numero de movimiento
         param in pcversion: codigo de version
         param in pcaccesorio: codigo del accesorio
         param in pctipacc: codigo del tipo de accesorio
         param in pfini: fecha de inicio o alta
         param in pivalacc: valor del accesorio
         param in ptdesacc: descripcion del accesorio
         param out mensajes : col·lecció de missatges
         return             : 0 -> Si todo OK
                              1 -> Si ha habido un error
   *************************************************************************/
   FUNCTION f_set_detautriesgos(
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcversion IN VARCHAR2,
      pcaccesorio IN VARCHAR2,
      pctipacc IN VARCHAR2,
      pfini IN DATE,
      pivalacc IN NUMBER,
      ptdesacc IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'parámetros - pnriesgo: ' || pnriesgo || ' pnmovimi:' || pnmovimi || ' pcversion:'
            || pcversion || ' pcaccesorio:' || pcaccesorio || ' pctipacc:' || pctipacc
            || ' pfini:' || pfini || ' pivalacc:' || pivalacc || ' ptdesacc:' || ptdesacc;
      vobject        VARCHAR2(200) := 'PAC_MD_PRODUCCION_AUT.f_set_detautriesgos';
      errores        t_ob_error;
      vobdetpoliza   ob_iax_detpoliza;
      vobauto        ob_iax_autriesgos;
      vtobacc        t_iax_autaccesorios;
      nerr           NUMBER;
   BEGIN
      -- Se obtiene el objeto detpoliza
      vobdetpoliza := pac_iobj_prod.f_getpoliza(mensajes);

      IF mensajes IS NOT NULL THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      -- Se obtiene el objeto autriesgo
      vobauto := pac_iobj_prod.f_partriesautomovil(vobdetpoliza, NVL(pnriesgo, 1), mensajes);

      IF mensajes IS NOT NULL THEN
         vpasexec := 3;
         RAISE e_object_error;
      END IF;

      -- Se obtiene la coleccion autaccesorios
      vtobacc := pac_iobj_prod.f_partautaccesorios(vobauto, mensajes);

      IF mensajes IS NOT NULL THEN
         vpasexec := 4;
         RAISE e_object_error;
      END IF;

      vpasexec := 8;

      -- Para el riesgo de entrada se introducen los datos en memoria con los valores de los parametros de entrada
      FOR vacc IN vtobacc.FIRST .. vtobacc.LAST LOOP
         IF vtobacc.EXISTS(vacc) THEN
            IF vtobacc(vacc).nriesgo = pnriesgo THEN
               vtobacc(vacc).nmovimi := pnmovimi;
               vtobacc(vacc).cversion := pcversion;
               vtobacc(vacc).caccesorio := pcaccesorio;
               vtobacc(vacc).ctipacc := pctipacc;
               vtobacc(vacc).ttipacc := ff_desvalorfijo(292, gidioma, pctipacc);
               vtobacc(vacc).fini := pfini;
               vtobacc(vacc).tdesacc := ptdesacc;
               nerr :=
                  pac_iobj_prod.f_set_partautaccesorios(pac_iax_produccion.poliza.det_poliza,
                                                        NVL(pnriesgo, 1), vtobacc, mensajes);

               IF nerr > 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001471,
                                                       'Error al guardar el accesorio');
                  RETURN 1;
               END IF;

               RETURN 0;
            END IF;
         END IF;
      END LOOP;

      vpasexec := 9;
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001472,
                                           'No se ha encontrado el accesorio');
      RETURN 1;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_detautriesgos;

-- Bug 9247 - APD - 06/03/2009 -- Fin Se crea la funcion f_set_detautriesgos

   -- Bug 9247 - APD - 23/03/2009 -- Se crea la funcion f_set_garanmodalidad
   /*************************************************************************
    Recupera las garantías que contiene una modalidad.
    param in p_nriesgo: identificador del riesgo
    param in p_cmodalidad: codigo de la modalidad
    param in p_solicit: código de solicitut
    param in p_nmovimi: número de movimiento
    param in p_pmode: modo
    param out garantaias: coleccion de garantias
    param out mensajes: mensajes de error
    return : ref cursor
    *************************************************************************/
   FUNCTION f_set_garanmodalidad(
      p_nriesgo IN NUMBER,
      p_cmodalidad IN NUMBER,
      p_solicit IN NUMBER,
      p_nmovimi IN NUMBER,
      p_pmode IN VARCHAR2,
      garantias OUT t_iax_garantias,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(2000)
                         := 'p_nriesgo = ' || p_nriesgo || '; p_cmodalidad = ' || p_cmodalidad;
      v_object       VARCHAR2(200) := 'PAC_MD_LISTVALORES_AUT.f_set_garanmodalidad';
      v_obgarantias  ob_iax_garantias;
      v_tgarantias   t_iax_garantias;
      nerr           NUMBER;
      nerr_preg      NUMBER;
      garp           t_iaxpar_garantias;
      det_poliza     ob_iax_detpoliza;
      vseleccionar   NUMBER;
      vcontrol       NUMBER;   -- Bug 29315/160991 - JSV - 12/12/13

       /*  CURSOR c_garantias IS
            SELECT g.cgarant
            FROM aut_garanmodalidad m, aut_desmodalidad d, garanpro g
            WHERE m.cmodalidad = d.cmodalidad
              AND m.cramo = g.cramo
              AND m.cmodali = g.cmodali
              AND m.ctipseg = g.ctipseg
              AND m.ccolect = g.ccolect
              AND m.cactivi = g.cactivi
              AND d.cidioma = pac_md_common.f_get_cxtidioma
              AND (m.cmodalidad = p_cmodalidad or p_cmodalidad = 0);*/
      -- BUG: 0027953/0151203 - JSV (INI)
       /*   CURSOR c_garantias IS
            SELECT DISTINCT m.cgarant
                       FROM aut_garanmodalidad m
                      WHERE cmodalidad = p_cmodalidad
                        AND m.cactivi = 0
                        AND(m.cramo, m.cmodali, m.ctipseg, m.ccolect, m.cactivi) IN(
                              SELECT g.cramo, g.cmodali, g.ctipseg, g.ccolect, g.cactivi
                                FROM garanpro g
                               WHERE m.cramo = g.cramo
                                 AND m.cmodali = g.cmodali
                                 AND m.ctipseg = g.ctipseg
                                 AND m.ccolect = g.ccolect
                                 AND m.cactivi = g.cactivi);
        */
      CURSOR c_garantias(
         vcramo IN NUMBER,
         vcmodali IN NUMBER,
         vctipseg IN NUMBER,
         vccolect IN NUMBER,
         vcactivi IN NUMBER) IS
         SELECT DISTINCT m.cgarant, norden, m.ctipgar, m.cdefecto
                    FROM garanpromodalidad m, garanpro g
                   WHERE m.cmodalidad = p_cmodalidad
                     AND m.cactivi = 0
                     AND m.cramo = vcramo
                     AND m.cmodali = vcmodali
                     AND m.ctipseg = vctipseg
                     AND m.cactivi = vcactivi
                     AND m.cramo = g.cramo
                     AND m.cmodali = g.cmodali
                     AND m.ccolect = g.ccolect
                     AND m.ctipseg = g.ctipseg
                     AND m.cactivi = g.cactivi
                     AND m.cramo = g.cramo
                     AND m.cgarant = g.cgarant
                ORDER BY norden;

      -- BUG: 0027953/0151203 - JSV (FIN)
      vnumerr        NUMBER;
      ries           t_iax_riesgos;
      vobriesgo      ob_iax_riesgos;
      autrie         ob_iax_autriesgos;
   BEGIN
      -- Bug 9678-AMC-02/04/2009- Recuperamos los datos de la poliza
      det_poliza := pac_iobj_prod.f_getpoliza(mensajes);

      IF det_poliza IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 32332,
                                              'No se ha inicializado correctamente');
         RAISE e_object_error;
      END IF;

      --BUG: 0027953/0151258 - JSV 21/08/2013 - INI
      v_pasexec := 1;
      -- Se obtiene la coleccion de riesgos
      ries := pac_iobj_prod.f_partpolriesgos(det_poliza, mensajes);

      -- Si no hay ningun riesgo dado de alta, devuelve al coleccion vacia inicializada
      IF mensajes IS NOT NULL THEN
         v_pasexec := 2;
         RAISE e_object_error;
      END IF;

      v_pasexec := 2;
      -- Se obtiene el objeto riesgo
      vobriesgo := pac_iobj_prod.f_partpolriesgo(det_poliza, p_nriesgo, mensajes);
-- Se obtiene el objeto autriesgo
      autrie := pac_iobj_prod.f_partriesautomovil(det_poliza, p_nriesgo, mensajes);
      autrie.cmodalidad := p_cmodalidad;

      IF p_cmodalidad IS NOT NULL THEN
         SELECT tmodalidad
           INTO autrie.tmodalidad
           FROM aut_desmodalidad
          WHERE cmodalidad = p_cmodalidad
            AND LENGTH(cmodalidad) = LENGTH(p_cmodalidad)
            AND cidioma = pac_md_common.f_get_cxtidioma;
      END IF;

      nerr := pac_iobj_prod.f_set_partriesautomovil(pac_iax_produccion.poliza.det_poliza,
                                                    p_nriesgo, vobriesgo, autrie, mensajes);
--BUG: 0027953/0151258 - JSV 21/08/2013 - FIN
      v_tgarantias := t_iax_garantias();
      -- Bug 9678-AMC-02/04/2009- Recuperamos las garantias definidas para el producto
      garp := pac_mdpar_productos.f_get_garantias(det_poliza.sproduc,
                                                  det_poliza.gestion.cactivi, p_nriesgo,
                                                  mensajes);

      FOR vgar IN garp.FIRST .. garp.LAST LOOP
         vseleccionar := 0;
         vcontrol := 0;

         FOR reg IN c_garantias(det_poliza.cramo, det_poliza.cmodali, det_poliza.ctipseg,
                                det_poliza.ccolect, det_poliza.gestion.cactivi) LOOP
            IF NVL(f_parproductos_v(det_poliza.sproduc, 'MODALIDAD_GAR_OBLIG'), 0) = 1 THEN
               vcontrol := 0;

-- Bug 29315/160991 - JSV - 12/12/13 - INI
               IF (reg.ctipgar = 2) THEN
                  vcontrol := 1;
               END IF;
            END IF;

-- Bug 29315/160991 - JSV - 12/12/13 - FIN
            IF garp(vgar).cgarant = reg.cgarant
                                               -- Bug 29315/160991 - JSV - 12/12/13
            THEN
               IF NVL(f_parproductos_v(det_poliza.sproduc, 'MODALIDAD_GAR_OBLIG'), 0) = 0 THEN
                  vseleccionar := 1;
               ELSE
                  --INI BUG 29315#c162767 -JDS- 08/01/2014
                  vseleccionar := 0;

                  IF reg.ctipgar = 2
                     OR reg.cdefecto = 1 THEN
                     vseleccionar := 1;
                  END IF;
               --FIN BUG 29315#c162767 -JDS- 08/01/2014
               END IF;

               v_tgarantias.EXTEND;
               v_tgarantias(v_tgarantias.LAST) := ob_iax_garantias();
               v_tgarantias(v_tgarantias.LAST).cgarant := garp(vgar).cgarant;
            END IF;
         END LOOP;

         vnumerr := pac_iax_produccion.f_grabargarantias(p_nriesgo, garp(vgar).cgarant,
                                                         vseleccionar, NULL, NULL, NULL, NULL,
                                                         mensajes);

         IF vnumerr > 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje
                                               (mensajes, 1, 9001102,
                                                'Error al insertar en el riesgo las garantias');
            RETURN 1;
         END IF;
      END LOOP;

      garantias := v_tgarantias;
      RETURN 0;   -- Todo OK
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_garanmodalidad;

-- Bug 9247 - APD - 23/03/2009 -- Se crea la funcion f_set_garanmodalidad
   FUNCTION f_get_auto_matric(
      pctipmat IN NUMBER,
      pcmatric IN VARCHAR2,
      psproduc IN NUMBER,   -- Bug 26435/142193 - 03/05/2013 - AMC
      pcactivi IN NUMBER,   -- Bug 26435/142193 - 03/05/2013 - AMC
      pcmodo IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_autriesgos IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
                         := 'parámetros - pctipmat: ' || pctipmat || ',pcmatric: ' || pcmatric;
      vobject        VARCHAR2(200) := 'PAC_MD_PRODUCCION_AUT.f_get_auto_matric';
      num_err        NUMBER;
      cur            sys_refcursor;
      cur2           sys_refcursor;
      cur3           sys_refcursor;
      v_tsquery      VARCHAR2(3000);
      v_tsquery1     VARCHAR2(3000);
      v_tsquery2     VARCHAR2(3000);
      riesgauto      ob_iax_autriesgos;
      vriesgauto     ob_iax_autriesgos;
      dispositivos   ob_iax_autdispositivos;
      accesorios     ob_iax_autaccesorios;
      vobdetpoliza   ob_iax_detpoliza;
      vcount         NUMBER;
      vctipveh       NUMBER;
      vctipveh2      NUMBER;
      vviginspdias   NUMBER;
      vcont          NUMBER;
      vsproduc       NUMBER;
      vnumerr        NUMBER;
      vsseguro       NUMBER;
      vnriesgo       NUMBER;
      vnmovimi       NUMBER;
      vsorden        NUMBER;
      vcinspreq      NUMBER;
      vcresultr      NUMBER;
      vqueryautos    VARCHAR2(3000);
      vqueryaccesorios VARCHAR2(3000);
      vquerydispositivos VARCHAR2(3000);
      vcvehnue       NUMBER;
      vnpuertas      NUMBER;
      vntara         NUMBER;
      vctransmision  NUMBER;
   BEGIN
      IF pcmatric IS NOT NULL THEN
         IF pctipmat IS NOT NULL
            AND pcmatric IS NOT NULL THEN
            -- Bug 26435/142193 - 03/05/2013 - AMC
            BEGIN
               SELECT ver.ctipveh
                 INTO vctipveh
                 FROM autriesgos rie, aut_versiones ver
                WHERE rie.cversion = ver.cversion
                  AND rie.ctipmat = pctipmat
                  AND rie.cmatric = pcmatric
                  AND ROWNUM = 1
                  AND ver.cempres = pac_md_common.f_get_cxtempresa;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vctipveh := NULL;
               WHEN OTHERS THEN
                  vctipveh := NULL;
            -- error
            END;

            IF vctipveh IS NOT NULL THEN
               SELECT ver.ctipveh
                 INTO vctipveh
                 FROM autriesgos rie, aut_versiones ver
                WHERE rie.cversion = ver.cversion
                  AND rie.ctipmat = pctipmat
                  AND rie.cmatric = pcmatric
                  AND ROWNUM = 1
                  AND ver.cempres = pac_md_common.f_get_cxtempresa;

               SELECT COUNT(1)
                 INTO vctipveh2
                 FROM aut_tipoactiprod
                WHERE cempres = pac_md_common.f_get_cxtempresa
                  AND sproduc = psproduc
                  AND cactivi = pcactivi
                  AND ctipveh = vctipveh;

               IF vctipveh2 = 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9905494);
                  RETURN NULL;
               END IF;
            END IF;

            -- Fi Bug 26435/142193 - 03/05/2013 - AMC
            v_tsquery :=
               'SELECT rie.cversion, rie.ctipmat, rie.cmatric,'
               || 'rie.cpeso, rie.ctransmision, rie.npuertas, '
               || 'rie.nbastid, rie.nplazas,  rie.cvehnue, rie.cuso, '
               || 'rie.csubuso,  rie.fmatric, rie.nkilometros, rie.ivehicu, '
               || 'rie.npma, rie.ntara, rie.ccolor, rie.cgaraje, rie.cusorem, rie.cremolque,rie.triesgo'
               || ', ver.cmodelo, ' || 'ver.cmarca, ver.ctipveh, ver.cclaveh,  ver.npuerta,'
               || ' rie.cpaisorigen, rie.cchasis,rie.ivehinue, rie.nkilometraje, TO_NUMBER(rie.ccilindraje), '
               || ' rie.codmotor, rie.cpintura, rie.ccaja, rie.ccampero,rie.ctipcarroceria, rie.cservicio, rie.corigen,rie.ctransporte, rie.anyo,rie.cmotor motorriesgo,ver.tversion, seguros.sproduc,seguros.sseguro,rie.nriesgo,rie.nmovimi '
               || ' FROM autriesgos rie, aut_versiones ver,seguros WHERE rie.sseguro = seguros.sseguro AND
                    rie.cversion = ver.cversion and  rie.ctipmat = nvl('''
               || pctipmat || ''',rie.ctipmat)  and rie.cmatric =''' || pcmatric
               || ''' and rie.sseguro = ( select max (sseguro) from autriesgos where ctipmat = nvl('''
               || pctipmat || ''', ctipmat) AND cmatric = ''' || pcmatric
               || ''') and ver.cempres = ' || pac_md_common.f_get_cxtempresa;
            -- Ini 33221/14488 -- ECP -- 04/11/2014
            v_tsquery1 :=
               'SELECT distinct caccesorio, ctipacc, fini, ivalacc, tdesacc, casegurable FROM autriesgos a, autdetriesgos b
               WHERE a.sseguro = b.sseguro and cmatric='''
               || pcmatric || '''';
            v_tsquery2 :=
               'SELECT distinct cdispositivo, cpropdisp, finicontrato, ffincontrato, ivaldisp, TO_CHAR(ncontrato), tdescdisp  FROM autriesgos a, autdisriesgos b
               WHERE a.sseguro = b.sseguro and cmatric='''
               || pcmatric || '''';
         -- Fin 33221/14488 -- ECP -- 04/11/2014
         END IF;

         -- Se obtiene el objeto detpoliza
         vobdetpoliza := pac_iobj_prod.f_getpoliza(mensajes);

         IF mensajes IS NOT NULL THEN
            RAISE e_object_error;
         END IF;

         -- Bug 32009/0188727 - APD - 03/10/2014 - se añade el modo 'MODIF_PROP'
         IF NVL(f_parproductos_v(vobdetpoliza.sproduc, 'CARGAR_AUTO'), 0) = 1
            AND INSTR(pcmodo, 'SUPLEMENTO', 1) = 0
            AND INSTR(pcmodo, 'MODIF_PROP', 1) = 0 THEN
            vnumerr := pac_propio.f_mig_autos(pac_md_common.f_get_cxtempresa, pcmatric,
                                              vobdetpoliza.sseguro, vqueryautos,
                                              vqueryaccesorios, vquerydispositivos);
            v_tsquery := v_tsquery || vqueryautos;
            -- Ini 33221/14488  -- ECP -- 04/11/2014
            vqueryaccesorios := v_tsquery1 || vqueryaccesorios;
            vquerydispositivos := v_tsquery2 || vquerydispositivos;

            -- Fin 33221/14488  -- ECP -- 04/11/2014
            IF vnumerr <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje
                                              (mensajes, 1, vnumerr,
                                               f_axis_literales(vnumerr,
                                                                pac_md_common.f_get_cxtidioma));
               RETURN NULL;
            END IF;
         END IF;

         -- fin Bug 32009/0188727 - APD - 03/10/2014
         IF v_tsquery IS NOT NULL THEN
            IF pac_iax_log.f_log_consultas(v_tsquery,
                                           'PAC_MD_PRODUCCION_AUT.f_get_auto_matric', 1, 2,
                                           mensajes) <> 0 THEN
               RAISE e_object_error;
            END IF;

            cur := pac_iax_listvalores.f_opencursor(v_tsquery, mensajes);
            vpasexec := 2;
            riesgauto := ob_iax_autriesgos();

            LOOP
               FETCH cur
                INTO riesgauto.cversion, riesgauto.ctipmat, riesgauto.cmatric,
                     riesgauto.cpeso, riesgauto.ctransmision, riesgauto.npuertas,
                     riesgauto.nbastid, riesgauto.nplazas, vcvehnue, riesgauto.cuso,
                     riesgauto.csubuso, riesgauto.fmatric, riesgauto.nkilometros,
                     riesgauto.ivehicu, riesgauto.npma, riesgauto.ntara, riesgauto.ccolor,
                     riesgauto.cgaraje, riesgauto.cusorem, riesgauto.cremolque,
                     riesgauto.triesgo, riesgauto.cmodelo, riesgauto.cmarca,
                     riesgauto.ctipveh, riesgauto.cclaveh, riesgauto.npuertas,
                     riesgauto.cpaisorigen, riesgauto.cchasis, riesgauto.ivehinue,
                     riesgauto.nkilometraje, riesgauto.ccilindraje, riesgauto.codmotor,
                     riesgauto.cpintura, riesgauto.ccaja, riesgauto.ccampero,
                     riesgauto.ctipcarroceria, riesgauto.cservicio, riesgauto.corigen,
                     riesgauto.ctransporte, riesgauto.anyo, riesgauto.cmotor,
                     riesgauto.tversion, vsproduc, vsseguro, vnriesgo, vnmovimi;

               -- Bug 32009/0188727 - APD - 03/10/2014 - Si no encuentra datos el cursor salir del LOOP
               EXIT WHEN cur%NOTFOUND;
               -- fin Bug 32009/0188727 - APD - 03/10/2014
               riesgauto.cvehnue := SUBSTR(TO_CHAR(vcvehnue), 1, 1);

               IF (vsseguro IS NOT NULL) THEN
                  IF (vquerydispositivos IS NOT NULL) THEN
                     IF pac_iax_log.f_log_consultas
                                                   (vquerydispositivos,
                                                    'PAC_MD_PRODUCCION_AUT.f_get_auto_matric',
                                                    1, 2, mensajes) <> 0 THEN
                        RAISE e_object_error;
                     END IF;

                     cur2 := pac_iax_listvalores.f_opencursor(vquerydispositivos, mensajes);
                     vpasexec := 3;
                     dispositivos := ob_iax_autdispositivos();
                     riesgauto.dispositivos := t_iax_autdispositivos();
                     dispositivos := ob_iax_autdispositivos();
                     riesgauto.dispositivos := t_iax_autdispositivos();

                     LOOP
                        FETCH cur2
                         INTO dispositivos.cdispositivo, dispositivos.cpropdisp,
                              dispositivos.finicontrato, dispositivos.ffincontrato,
                              dispositivos.ivaldisp, dispositivos.ncontrato,
                              dispositivos.tdescdisp;

                        EXIT WHEN cur2%NOTFOUND;
                        riesgauto.dispositivos.EXTEND;
                        dispositivos.cversion := riesgauto.cversion;
                        dispositivos.cmarcado := 1;
                        riesgauto.dispositivos(riesgauto.dispositivos.LAST) := dispositivos;
                     END LOOP;

                     IF (cur2%ROWCOUNT = 0) THEN
                        riesgauto.dispositivos := NULL;
                     END IF;
                  END IF;

                  IF (vqueryaccesorios IS NOT NULL) THEN
                     IF pac_iax_log.f_log_consultas
                                                   (vqueryaccesorios,
                                                    'PAC_MD_PRODUCCION_AUT.f_get_auto_matric',
                                                    1, 2, mensajes) <> 0 THEN
                        RAISE e_object_error;
                     END IF;

                     cur3 := pac_iax_listvalores.f_opencursor(vqueryaccesorios, mensajes);
                     vpasexec := 4;
                     accesorios := ob_iax_autaccesorios();
                     riesgauto.accesorios := t_iax_autaccesorios();

                     LOOP
                        FETCH cur3
                         INTO accesorios.caccesorio, accesorios.ctipacc, accesorios.fini,
                              accesorios.ivalacc, accesorios.tdesacc, accesorios.casegurable;

                        EXIT WHEN cur3%NOTFOUND;
                        riesgauto.accesorios.EXTEND;
                        accesorios.cversion := riesgauto.cversion;
                        accesorios.cmarcado := 1;
                        riesgauto.accesorios(riesgauto.accesorios.LAST) := accesorios;
                     END LOOP;

                     IF (cur3%ROWCOUNT = 0) THEN
                        riesgauto.accesorios := NULL;
                     END IF;
                  END IF;
               END IF;

               IF NVL(f_parproductos_v(vobdetpoliza.sproduc, 'CARGAR_AUTO'), 0) = 1 THEN
                  IF vsseguro IS NULL THEN
                     BEGIN
                        SELECT vcomercial
                          INTO riesgauto.ivehinue
                          FROM aut_versiones_anyo d
                         WHERE d.cversion = riesgauto.cversion
                           AND anyo = (SELECT MAX(anyo)
                                         FROM aut_versiones_anyo d
                                        WHERE d.cversion = riesgauto.cversion);

                        SELECT vcomercial
                          INTO riesgauto.ivehicu
                          FROM aut_versiones_anyo d
                         WHERE d.cversion = riesgauto.cversion
                           AND anyo = riesgauto.anyo;
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;
                  END IF;
               END IF;

               IF vqueryautos IS NOT NULL THEN
                  --En migración si los campos NPUERTAS, NTARA y CTRANSMISION es nulo, deberemos coger los valores de aut_versiones -->BUG 30256#c168957, 10-03-2014
                  BEGIN
                     SELECT npuerta, ntara, ctransmision
                       INTO vnpuertas, vntara, vctransmision
                       FROM aut_versiones
                      WHERE cversion = riesgauto.cversion;

                     IF (riesgauto.npuertas IS NULL) THEN
                        riesgauto.npuertas := vnpuertas;
                     END IF;

                     IF (riesgauto.ntara IS NULL) THEN
                        riesgauto.ntara := vntara;
                     END IF;

                     IF (riesgauto.ctransmision IS NULL) THEN
                        riesgauto.ctransmision := vctransmision;
                     END IF;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        NULL;
                  END;
               END IF;

               IF vsproduc IS NOT NULL THEN
                  IF NVL(pac_parametros.f_parproducto_n(vsproduc, 'GESTION_IR'), 0) = 1 THEN
                     BEGIN
                        vnumerr :=
                           pac_cfg.f_get_user_accion_permitida
                                                            (pac_md_common.f_get_cxtusuario,
                                                             'VIGENCIA_INSPECCION', vsproduc,
                                                             pac_md_common.f_get_cxtempresa(),
                                                             vviginspdias);
                        vnumerr := 0;

                        IF vviginspdias IS NULL THEN
                           vviginspdias :=
                              pac_mdpar_productos.f_get_parproducto('VIGENCIA_ORDENINSP',
                                                                    vsproduc);
                        END IF;

                        SELECT COUNT(1)
                          INTO vcont
                          FROM ir_inspecciones ii, ir_ordenes io
                         WHERE ii.sorden = io.sorden
                           AND ii.cempres = io.cempres
                           AND ii.cestado = 3
                           AND io.cmatric LIKE pcmatric
                           AND ii.cempres = pac_md_common.f_get_cxtempresa
                           AND f_sysdate - ii.finspeccion < vviginspdias;

                        IF vcont > 0 THEN
                           riesgauto.inspeccion_vigente := 1;
                           pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9905706);
                        ELSE
                           riesgauto.inspeccion_vigente := 0;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user, 'PAC_MD_INSPECCION', 1,
                                       ' f_get_auto_matric', SQLERRM);
                     END;
                  END IF;
               END IF;

               -- Bug 32009/0188727 - APD - 03/10/2014 - si encuentra datos, ya sea porque
               -- exista la matricula en AUT_MIG_MATRICULAS o porque la matricula ya existía
               -- en otra poliza, se deben copiar los dispositivos y accesorios que se han
               -- encontrado
               --EXIT WHEN vsseguro IS NOT NULL;
               -- fin Bug 32009/0188727 - APD - 03/10/2014
               IF (vquerydispositivos IS NOT NULL) THEN
                  IF pac_iax_log.f_log_consultas(vquerydispositivos,
                                                 'PAC_MD_PRODUCCION_AUT.f_get_auto_matric', 1,
                                                 2, mensajes) <> 0 THEN
                     RAISE e_object_error;
                  END IF;

                  cur2 := pac_iax_listvalores.f_opencursor(vquerydispositivos, mensajes);
                  vpasexec := 3;
                  dispositivos := ob_iax_autdispositivos();
                  riesgauto.dispositivos := t_iax_autdispositivos();

                  LOOP
                     FETCH cur2
                      INTO dispositivos.cdispositivo, dispositivos.cpropdisp,
                           dispositivos.finicontrato, dispositivos.ffincontrato,
                           dispositivos.ivaldisp, dispositivos.ncontrato,
                           dispositivos.tdescdisp;

                     EXIT WHEN cur2%NOTFOUND;
                     riesgauto.dispositivos.EXTEND;
                     dispositivos.cversion := riesgauto.cversion;
                     dispositivos.cmarcado := 1;
                     riesgauto.dispositivos(riesgauto.dispositivos.LAST) := dispositivos;
                  END LOOP;

                  IF (cur2%ROWCOUNT = 0) THEN
                     riesgauto.dispositivos := NULL;
                  END IF;
               END IF;

               IF (vqueryaccesorios IS NOT NULL) THEN
                  IF pac_iax_log.f_log_consultas(vqueryaccesorios,
                                                 'PAC_MD_PRODUCCION_AUT.f_get_auto_matric', 1,
                                                 2, mensajes) <> 0 THEN
                     RAISE e_object_error;
                  END IF;

                  cur3 := pac_iax_listvalores.f_opencursor(vqueryaccesorios, mensajes);
                  vpasexec := 4;
                  accesorios := ob_iax_autaccesorios();
                  riesgauto.accesorios := t_iax_autaccesorios();

                  LOOP
                     FETCH cur3
                      INTO accesorios.caccesorio, accesorios.ctipacc, accesorios.fini,
                           accesorios.ivalacc, accesorios.tdesacc, accesorios.casegurable;

                     EXIT WHEN cur3%NOTFOUND;
                     riesgauto.accesorios.EXTEND;
                     accesorios.cversion := riesgauto.cversion;
                     accesorios.cmarcado := 1;
                     riesgauto.accesorios(riesgauto.accesorios.LAST) := accesorios;
                  END LOOP;

                  IF (cur3%ROWCOUNT = 0) THEN
                     riesgauto.accesorios := NULL;
                  END IF;
               END IF;
            -- Bug 32009/0188727 - APD - 03/10/2014 - se sube al principio del LOOP el codigo
            --EXIT WHEN cur%NOTFOUND;
            END LOOP;

            -- Bug 32009/0188727 - APD - 03/10/2014 - si el cursor no ha recuperado datos se
            -- debe continuar con la misma informacion en accesorios y dispositivos
            IF (cur%ROWCOUNT = 0)
               OR(cur%ROWCOUNT <> 0
                  AND vsseguro IS NOT NULL) THEN
               --INI 32009#c189879 , JDS 24/10/2014
               vriesgauto :=
                  pac_iobj_prod.f_partriesautomovil(pac_iax_produccion.poliza.det_poliza, 1,
                                                    mensajes);

               IF vriesgauto.accesorios IS NOT NULL
                  OR vriesgauto.dispositivos IS NOT NULL THEN
                  riesgauto := ob_iax_autriesgos();

                  IF vriesgauto.accesorios IS NOT NULL THEN
                     riesgauto.accesorios := vriesgauto.accesorios;
                  END IF;

                  IF vriesgauto.dispositivos IS NOT NULL THEN
                     riesgauto.dispositivos := vriesgauto.dispositivos;
                  END IF;
               END IF;
            --FIN 32009#c189879 , JDS 24/10/2014
            END IF;
         -- fin Bug 32009/0188727 - APD - 03/10/2014
         END IF;
      END IF;

      RETURN riesgauto;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_auto_matric;

   FUNCTION f_hay_homologacion(
      pcversion IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pvalorcomercial OUT NUMBER,
      pvalorcomercial_nuevo OUT NUMBER,
      phomologado OUT NUMBER,
      pmensajemostrar OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vcversionhomologo aut_versiones.cversionhomologo%TYPE;
      vnumerr        NUMBER;
   BEGIN
      BEGIN
         -- Bug 26638/160933 - 11/12/2013 - AMC
         SELECT   /*vcomercial,
                  (SELECT vcomercial
                     FROM aut_versiones_anyo d
                    WHERE d.cversion = pcversion
                      AND anyo = (SELECT MAX(anyo)
                                    FROM aut_versiones_anyo d
                                   WHERE d.cversion = pcversion)),*/
                cversionhomologo
           INTO   --pvalorcomercial,
                  --pvalorcomercial_nuevo,
                vcversionhomologo
           FROM aut_versiones_anyo d, aut_versiones av, estautriesgos ar, estseguros es
          WHERE d.cversion = pcversion
            AND av.cversion = d.cversion
            AND cestado = 3
            AND ar.anyo = d.anyo
            AND ar.sseguro = psseguro
            AND ar.sseguro = es.sseguro
            AND ar.nriesgo = pnriesgo;

         vnumerr := pac_autos.f_get_valorauto(psseguro, pnriesgo, NULL, pcversion, 2,
                                              pvalorcomercial, pvalorcomercial_nuevo);
         -- Fi Bug 26638/160933 - 11/12/2013 - AMC
         phomologado := 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            phomologado := 0;
      END;

      IF phomologado > 0 THEN
         pmensajemostrar := f_axis_literales(9905130, pac_md_common.f_get_cxtidioma) || ' '
                            || pcversion || ' '
                            || f_axis_literales(9905131, pac_md_common.f_get_cxtidioma) || ' '
                            || vcversionhomologo || ', '
                            || f_axis_literales(9905219, pac_md_common.f_get_cxtidioma);
      END IF;

      RETURN phomologado;
   END f_hay_homologacion;

   -- BUG: 0027953/0151258 - JSV 21/08/2013 - INI
/*************************************************************************
    Recupera las garantías que contiene una modalidad.
    param in p_nriesgo: identificador del riesgo
    param in p_cmodalidad: codigo de la modalidad
    param in p_solicit: código de solicitut
    param in p_nmovimi: número de movimiento
    param in p_pmode: modo
    param out garantaias: coleccion de garantias
    param out mensajes: mensajes de error
    return : ref cursor
    *************************************************************************/
   FUNCTION f_get_garanmodalidad(
      p_nriesgo IN NUMBER,
      p_cmodalidad IN NUMBER,
      p_solicit IN NUMBER,
      p_nmovimi IN NUMBER,
      p_pmode IN VARCHAR2,
      garantias OUT t_iax_garantias,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(2000)
                         := 'p_nriesgo = ' || p_nriesgo || '; p_cmodalidad = ' || p_cmodalidad;
      v_object       VARCHAR2(200) := 'PAC_MD_LISTVALORES_AUT.f_get_garanmodalidad';
      v_obgarantias  ob_iax_garantias;
      v_tgarantias   t_iax_garantias;
      nerr           NUMBER;
      nerr_preg      NUMBER;
      garp           t_iaxpar_garantias;
      det_poliza     ob_iax_detpoliza;
      ries           t_iax_riesgos;
      vobriesgo      ob_iax_riesgos;
      autrie         ob_iax_autriesgos;

      CURSOR c_garantias IS
         SELECT DISTINCT m.cgarant, norden, g.sproduc
                    FROM garanpromodalidad m, garanpro g
                   WHERE (p_cmodalidad IS NULL
                          OR m.cmodalidad = p_cmodalidad)
                     AND m.cactivi = 0
                     AND m.cramo = g.cramo
                     AND m.cmodali = g.cmodali
                     AND m.ccolect = g.ccolect
                     AND m.ctipseg = g.ctipseg
                     AND m.cactivi = g.cactivi
                     AND m.cramo = g.cramo
                     AND m.cgarant = g.cgarant
                ORDER BY norden;
   BEGIN
      -- Bug 9678-AMC-02/04/2009- Recuperamos los datos de la poliza
      det_poliza := pac_iobj_prod.f_getpoliza(mensajes);

      IF det_poliza IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 32332,
                                              'No se ha inicializado correctamente');
         RAISE e_object_error;
      END IF;

      v_pasexec := 1;
      -- Se obtiene la coleccion de riesgos
      ries := pac_iobj_prod.f_partpolriesgos(det_poliza, mensajes);

      -- Si no hay ningun riesgo dado de alta, devuelve al coleccion vacia inicializada
      IF mensajes IS NOT NULL THEN
         v_pasexec := 2;
         RAISE e_object_error;
      END IF;

      v_pasexec := 2;
      -- Se obtiene el objeto riesgo
      vobriesgo := pac_iobj_prod.f_partpolriesgo(det_poliza, p_nriesgo, mensajes);
-- Se obtiene el objeto autriesgo
      autrie := pac_iobj_prod.f_partriesautomovil(det_poliza, p_nriesgo, mensajes);
      autrie.cmodalidad := p_cmodalidad;

      IF p_cmodalidad IS NOT NULL THEN
         SELECT tmodalidad
           INTO autrie.tmodalidad
           FROM aut_desmodalidad
          WHERE cmodalidad = p_cmodalidad
            AND LENGTH(cmodalidad) = LENGTH(p_cmodalidad)
            AND cidioma = pac_md_common.f_get_cxtidioma;
      END IF;

      v_tgarantias := t_iax_garantias();
      -- Bug 9678-AMC-02/04/2009- Recuperamos las garantias definidas para el producto
      garp := pac_mdpar_productos.f_get_garantias(det_poliza.sproduc,
                                                  det_poliza.gestion.cactivi, p_nriesgo,
                                                  mensajes);

      -- Bug 9678-AMC-02/04/2009- Recorremos todas las garantias de la modalidad
      FOR reg IN c_garantias LOOP
         -- Bug 9678-AMC-02/04/2009- Para cada garantia de la modalidad la buscamos en el producto
         FOR vgar IN garp.FIRST .. garp.LAST LOOP
            -- Bug 9678-AMC-02/04/2009- Hacemos el traspaso a la colección de garantias de la modalidad
            IF garp(vgar).cgarant = reg.cgarant
               AND reg.sproduc = det_poliza.sproduc THEN
               v_tgarantias.EXTEND;
               v_tgarantias(v_tgarantias.LAST) := ob_iax_garantias();
               v_tgarantias(v_tgarantias.LAST).cgarant := garp(vgar).cgarant;
               v_tgarantias(v_tgarantias.LAST).nmovimi := p_nmovimi;
               v_tgarantias(v_tgarantias.LAST).nmovima := p_nmovimi;
               v_tgarantias(v_tgarantias.LAST).ctipgar := garp(vgar).ctipgar;
               v_tgarantias(v_tgarantias.LAST).cobliga := 1;
               v_tgarantias(v_tgarantias.LAST).icapital := NULL;
               v_tgarantias(v_tgarantias.LAST).finiefe := det_poliza.gestion.fefecto;
               v_tgarantias(v_tgarantias.LAST).norden := garp(vgar).norden;
               v_tgarantias(v_tgarantias.LAST).cdetalle :=
                  pac_mdpar_productos.f_get_detallegar(det_poliza.sproduc, garp(vgar).cgarant,
                                                       mensajes);

               IF NVL(v_tgarantias(v_tgarantias.LAST).crevali, 0) <> 0 THEN
                  v_tgarantias(v_tgarantias.LAST).crevali := det_poliza.crevali;
                  v_tgarantias(v_tgarantias.LAST).prevali := det_poliza.prevali;
               ELSE
                  v_tgarantias(v_tgarantias.LAST).crevali := garp(vgar).crevali;
                  v_tgarantias(v_tgarantias.LAST).prevali := garp(vgar).prevali;
               END IF;

               v_tgarantias(v_tgarantias.LAST).ctipo :=
                  pac_iaxpar_productos.f_get_pargarantia('TIPO', det_poliza.sproduc,
                                                         garp(vgar).cgarant);

               IF garp(vgar).ctipgar IN(2, 4) THEN   -- Bug 9678-AMC-02/04/2009- indica que la garantia es obligatoria
                  -- Bug 9678-AMC-02/04/2009- 2 obligatoria    4 depenent obligatoria
                  v_tgarantias(v_tgarantias.LAST).cobliga := 1;
               END IF;

               IF garp(vgar).ctipcap = 1 THEN
                  -- Bug 9678-AMC-02/04/2009- indica que el capital es fitxe i sha de mostrar el valor del capital
                  v_tgarantias(v_tgarantias.LAST).icapital := garp(vgar).icapmax;
               END IF;
            END IF;
         END LOOP;
      END LOOP;

      IF nerr > 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001102,
                                              'Error al insertar en el riesgo las garantias');
         RETURN 1;
      END IF;

      garantias := v_tgarantias;
      RETURN 0;   -- Todo OK
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_garanmodalidad;
-- BUG: 0027953/0151258 - JSV 21/08/2013 - FIN
END pac_md_produccion_aut;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_PRODUCCION_AUT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PRODUCCION_AUT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PRODUCCION_AUT" TO "PROGRAMADORESCSI";
