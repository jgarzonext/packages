--------------------------------------------------------
--  DDL for Package Body PAC_MNTPROD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MNTPROD" AS
/******************************************************************************
   NOMBRE:       PAC_MNTPROD
   PROPÓSITO:  Mantenimiento productos. gestión

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        14/04/2008   JRB                1. Creación del package.
   2.0        29/12/2008   XCG                2. Modificació package. (8510) afegir funcions
   3.0        29/04/2009   ICV                3. Modificació package. (9532,8510)
   4.0        29/06/2009   AMC                4. Se añaden nuevas funciones bug 10557
   5.0        05/05/2010   AMC                5. Bug 14284. Se añaden nuevas funciones.
   6.0        27/05/2010   AMC                6. Se añade la función f_del_garantia bug 14723
   7.0        04/06/2010   PFA                7. 14588: CRT001 - Añadir campo compañia productos
   8.0        04/06/2010   AMC                8. Se añaden nuevas funciones bug 14748
   9.0        16/06/2010   AMC                9. Se añaden nuevas funciones bug 15023
   10.0       21/06/2010   AMC                10. Se añaden nuevas funciones bug 15148
   11.0       29/06/2010   AMC                11. Se añaden nuevas funciones bug 15149
   12.0       23/07/2010   PFA                12. 15513: MDP - Alta de productos
   13.0       15/12/2010   LCF                13. 16684: Anyadir ccompani para productos especiales
   14.0       08/05/2012   APD                14. 0022049: MDP - TEC - Visualizar garantías y sub-garantias
   15.0       17/05/2012   MDS                15. 0022253: LCOL - Duración del cobro como campo desplegable
   16.0       23/01/2014   AGG                16. 0027306: POSS518 (POSSF200)- Resolucion de Incidencias FASE 1-2: Tecnico - VI - Temporales anuales renovables
   17.0       18/02/2014   DEV                17. 0029920: POSFC100-Taller de Productos
   18.0       25/09/2014   JTT                18. 0032367: Añadimos el 'Codigo contable' en el bloque de Administracion
                                                  0032620: Añadimos el 'Tipo de provision' en el bloque Datos tecnicos
******************************************************************************/

   /**************************************************************************
     Inserta un nuevo registro en la tabla companipro. Si existe, lo actualiza
     param in psproduc     : Codigo del producto
     param in pccompani    : Codigo de la compania
     param in pcagencorr   : Codigo del agente en la compania/producto
     param in psproducesp  : Codigo del producto especifico
   **************************************************************************/
   FUNCTION f_insert_companipro(
      psproduc IN NUMBER,
      pccompani IN NUMBER,
      pcagencorr IN VARCHAR2,
      psproducesp IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      ---insersió-----------
      INSERT INTO companipro
                  (sproduc, ccompani, cagencorr, sproducesp)
           VALUES (psproduc, pccompani, pcagencorr, psproducesp);

      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         UPDATE companipro
            SET cagencorr = pcagencorr,
                sproducesp = psproducesp
          WHERE sproduc = psproduc
            AND ccompani = pccompani
            AND sproducesp = psproducesp;

         RETURN 0;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MNTPRROD.f_insert_companipro', NULL,
                     'Error al insertar en la tabla companipro', SQLERRM);
         RETURN(SQLERRM);
   END f_insert_companipro;

   /**************************************************************************
     Borra un registro de la tabla companipro.
     param in psproduc     : Codigo del producto
     param in pccompani    : Codigo de la compania
   **************************************************************************/
   FUNCTION f_delete_companipro(psproduc IN NUMBER, pccompani IN NUMBER, psproducesp IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      DELETE FROM companipro
            WHERE sproduc = psproduc
              AND ccompani = pccompani
              AND sproducesp = psproducesp;

      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_DURPERIODOPROD.f_delete_companipro', NULL,
                     'Error al borrar el registro en la tabla companipro', SQLERRM);
         RETURN(SQLERRM);
   END f_delete_companipro;

   /*************************************************************************
       Valida los datos generales de un producto
       param in psproduc   : código del producto
       param in pcramo      : código del ramo
       param in pcmodali    : código de la modalidad
       param in pctipseg    : código del tipo de seguro
       param in pccolect    : código de colectividad
       param in pcactivo    : indica si el producto está activo
       param in pctermfin   : contratable desde el terminal financiero, 0.-Si, 1.-No
       param in pctiprie    : tipo de riesgo
       param in pcobjase    : Tipo de objeto asegurado
       param in pcsubpro    : Código de subtipo de producto
       param in pnmaxrie    : maximo riesgo
       param in pc2cabezas  : c2cabezas
       param in pcagrpro    : Codigo agrupación de producto
       param in pcdivisa    : Clave de Divisa
       return              : 0 si ha ido bien
                             numero error si ha ido mal
   *************************************************************************/
   FUNCTION f_validadatosgenerales(
      psproduc IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivo IN NUMBER,
      pctermfin IN NUMBER,
      pctiprie IN NUMBER,
      pcobjase IN NUMBER,
      pcsubpro IN NUMBER,
      pnmaxrie IN NUMBER,
      pc2cabezas IN NUMBER,
      pcagrpro IN NUMBER,
      pcdivisa IN NUMBER,
      pcompani IN NUMBER)
      RETURN NUMBER IS
      vc2cabezas     NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MNTPROD.F_ValidaDatosGenerales';
      vexiste        NUMBER;
   BEGIN
      IF psproduc IS NULL THEN
         BEGIN
            SELECT COUNT(1)
              INTO vexiste
              FROM productos
             WHERE cramo = pcramo
               AND cmodali = pcmodali
               AND ctipseg = pctipseg
               AND ccolect = pccolect;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'numerr: ' || 140720);
               RETURN 140720;   --NO ESTÁ INFORMADO EL PSPRODUC Y EXISTE EL PRODUCTO POR RAMO,MODALI,TIPSEG,CCOLECT
         END;

         IF vexiste > 0 THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'numerr: ' || 140720);
            RETURN 140720;   --NO ESTÁ INFORMADO EL PSPRODUC Y EXISTE EL PRODUCTO POR RAMO,MODALI,TIPSEG,CCOLECT
         END IF;
      END IF;

      vpasexec := 2;
      /******************* anulado jmf 25441 05-02-2013
       IF pcsubpro IN(2, 3) THEN
          IF pnmaxrie IS NULL THEN
             p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'numerr: ' || 1000021);
             RETURN 1000021;   --NMAXRIE NO ESTÁ INFORMADO
          END IF;
       END IF;
      ******************* anulado jmf 25441 05-02-2013 */
      vpasexec := 3;

      IF pcramo IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'numerr: ' || 1000022);
         RETURN 1000022;   --CRAMO
      END IF;

      IF pcmodali IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'numerr: ' || 1000023);
         RETURN 1000023;   --CMODALI
      END IF;

      IF pctipseg IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'numerr: ' || 1000024);
         RETURN 1000024;   --CTIPSEG
      END IF;

      IF pccolect IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'numerr: ' || 1000025);
         RETURN 1000025;   --CCOLECT
      END IF;

      IF pcactivo IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'numerr: ' || 1000026);
         RETURN 1000026;   --CACTIVO
      END IF;

      IF pctiprie IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'numerr: ' || 1000027);
         RETURN 1000027;   --CTIPRIE
      END IF;

      IF pcsubpro IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'numerr: ' || 1000028);
         RETURN 1000028;   --CSUBPRO
      END IF;

      IF pcagrpro IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'numerr: ' || 1000029);
         RETURN 1000029;   --CAGRPRO
      END IF;

      IF pcdivisa IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'numerr: ' || 1000030);
         RETURN 1000030;   --CDIVISA
      END IF;

      IF pcobjase IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'numerr: ' || 9904765);
         RETURN 9904765;   --COBJBASE
      END IF;

      /*  IF pcompani IS NULL THEN
           p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'numerr: ' || 9901329);
           RETURN 1000030;   --CCOMPANI
        END IF;*/
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 111866;
   END f_validadatosgenerales;

   /*************************************************************************
      Inserta o modifica los datos de un producto
      param in psproduc   : código del producto
      param in pcramo      : código del ramo
      param in pcmodali    : código de la modalidad
      param in pctipseg    : código del tipo de seguro
      param in pccolect    : código de colectividad
      param in pcactivo    : indica si el producto está activo
      param in pctermfin   : contratable desde el terminal financiero, 0.-Si, 1.-No
      param in pctiprie    : tipo de riesgo
      param in pcobjase    : Tipo de objeto asegurado
      param in pcsubpro    : Código de subtipo de producto
      param in pnmaxrie    : maximo riesgo
      param in pc2cabezas  : c2cabezas
      param in pcagrpro    : Codigo agrupación de producto
      param in pcdivisa    : Clave de Divisa
      return              : 0 si ha ido bien
                            numero error si ha ido mal
   *************************************************************************/
   FUNCTION f_set_datosgenerales(
      psproduc IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivo IN NUMBER,
      pctermfin IN NUMBER,
      pctiprie IN NUMBER,
      pcobjase IN NUMBER,
      pcsubpro IN NUMBER,
      pnmaxrie IN NUMBER,
      pc2cabezas IN NUMBER,
      pcagrpro IN NUMBER,
      pcdivisa IN NUMBER,
      pcprprod IN NUMBER,
      pcompani IN NUMBER)
      RETURN NUMBER IS
      vc2cabezas     NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MNTPROD.F_Set_DatosGenerales';
      vcreccob       NUMBER;
      vcempres       NUMBER;
   BEGIN
      IF pcramo IS NULL
         OR pcmodali IS NULL
         OR pctipseg IS NULL
         OR pccolect IS NULL
         OR pcactivo IS NULL THEN
         RETURN 110080;
      END IF;

      vpasexec := 3;

      BEGIN
         SELECT cempres
           INTO vcempres
           FROM codiram
          WHERE cramo = pcramo;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
            RETURN 105541;
      END;

      IF ff_es_correduria(vcempres) = 1 THEN
         vcreccob := 1;
      ELSE
         vcreccob := 0;
      END IF;

      vpasexec := 12;

      INSERT INTO productos
                  (
                   --C2CABEZAS,
                   ctipseg, ccolect, cramo, cmodali, cagrpro, csubpro, cactivo, ctipreb,
                   ctipges, creccob, ctippag, cpagdef, cduraci, ctempor, ctarman, ctipefe,
                   cgarsin, cvalman, ctiprie, cvalfin, cprotec, crecfra, cimppri, cimptax,
                   cimpcon, cctacor, cdivisa, cmodnre, ctermfin, cobjase, nmaxrie, cprprod,
                   ccompani)
           VALUES (
                   --NVL(PC2CABEZAS, 0),
                   pctipseg, pccolect, pcramo, pcmodali, pcagrpro, pcsubpro, pcactivo, 1,
                   1, vcreccob, 2, 12, 0, 0, 0, 0,
                   1, 0, pctiprie, 1, 1, 0, 1, 1,
                   1, 0, pcdivisa, 1, pctermfin, pcobjase, pnmaxrie, pcprprod,
                   pcompani);

      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         BEGIN
            UPDATE productos
               SET
                   --C2CABEZAS = NVL(PC2CABEZAS,0),
                   --sólo se actualiza lo que llega.
                   cagrpro = pcagrpro,
                   csubpro = pcsubpro,
                   cactivo = pcactivo,
                   --ctipreb = 1,
                   --ctipges = 1,
                   creccob = vcreccob,
                   --ctippag = 2,
                   --cpagdef = 12,
                   --cduraci = 0,
                   --ctempor = 0,
                   --ctarman = 0,
                   --ctipefe = 0,
                   --cgarsin = 1,
                   --cvalman = 0,
                   ctiprie = pctiprie,
                   --cvalfin = 1,
                   --cprotec = 1,
                   --crecfra = 0,
                   --cimppri = 1,
                   --cimptax = 1,
                   --cimpcon = 1,
                   --cctacor = 0,
                   cdivisa = pcdivisa,
                   --cmodnre = 1,
                   ctermfin = pctermfin,
                   cobjase = pcobjase,
                   nmaxrie = pnmaxrie,
                   ccompani = pcompani,
                   cprprod = pcprprod
             WHERE sproduc = psproduc
               AND cramo = pcramo
               AND cmodali = pcmodali
               AND ctipseg = pctipseg
               AND ccolect = pccolect;

            RETURN 0;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN 110080;
         END;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 110080;
   END f_set_datosgenerales;

   /*************************************************************************
      Inserta o modifica la descripción del producto
      param in pcramo      : código del ramo
      param in pcmodali    : código de la modalidad
      param in pctipseg    : código del tipo de seguro
      param in pccolect    : código de colectividad
      param in pcidioma    : código de idioma
      param in ptrotulo    : Abreviación del título
      param in pttitulo    : Título del producto
      return               : 0 si ha ido bien
                            numero error si ha ido mal
   *************************************************************************/
   FUNCTION f_set_prodtitulo(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcidioma IN NUMBER,
      ptrotulo IN VARCHAR2,
      pttitulo IN VARCHAR2)
      RETURN NUMBER IS
      vc2cabezas     NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'cramo=' || pcramo || ' cmodali=' || pcmodali || ' ctipseg=' || pctipseg
            || ' ccolect=' || pccolect;
      vobject        VARCHAR2(200) := 'PAC_MNTPROD.F_Set_ProdTitulo';
      vcreccob       NUMBER;
      vcempres       NUMBER;
   BEGIN
      IF pcidioma IS NULL
         OR pttitulo IS NULL
         OR ptrotulo IS NULL
         OR pcramo IS NULL
         OR pcmodali IS NULL
         OR pctipseg IS NULL
         OR pccolect IS NULL THEN
         RETURN 103653;
      END IF;

      BEGIN
         SELECT cempres
           INTO vcempres
           FROM codiram
          WHERE cramo = pcramo;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
            RETURN 105541;
      END;

      IF ff_es_correduria(vcempres) = 1 THEN
         vcreccob := 1;
      ELSE
         vcreccob := 0;
      END IF;

      INSERT INTO titulopro
                  (cramo, cmodali, ctipseg, ccolect, cidioma, ttitulo, trotulo)
           VALUES (pcramo, pcmodali, pctipseg, pccolect, pcidioma, pttitulo, ptrotulo);

      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         BEGIN
            UPDATE titulopro
               SET ttitulo = pttitulo,
                   trotulo = ptrotulo
             WHERE cramo = pcramo
               AND cmodali = pcmodali
               AND ctipseg = pctipseg
               AND ccolect = pccolect
               AND cidioma = pcidioma;

            RETURN 0;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN 103653;
         END;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 103653;
   END f_set_prodtitulo;

   /*************************************************************************
       Valida los datos de gestión de un producto
       param in psproduc   : código del producto
       param in cduraci    : código de la duración
       param in ctempor    : Permite temporal
       param in ndurcob    : Duración pagos
       param in cdurmin    : Duración mínima
       param in nvtomin    : Tipo
       param in cdurmax    : duración máxima póliza
       param in nvtomax    : Número años máximo para el vto.
       param in ctipefe    : Tipo de efecto
       param in nrenova    : renovación
       param in cmodnre    : Fecha de renovación
       param in cprodcar   : Si ha pasado cartera
       param in crevali    : Código de revalorización
       param in prevali    : Porcentaje revalorización
       param in irevali    : Importe revalorización
       param in ctarman    : tarificación puede ser manual
       param in creaseg    : creaseg
       param in creteni    : Indicador de propuesta
       param in cprorra    : tipo prorrateo
       param in cprimin    : tipo de prima minima
       param in iprimin    : importe mínimo prima de recibo en emisión
       param in cclapri    : Fórmula prima mínima
       param in ipminfra   : Prima mínima fraccionada
       param in nedamic    : Edad mín ctr
       param in ciedmic    : Edad real
       param in nedamac    : Edad máx. ctr
       param in ciedmac    : Edad Real. Check por defecto = 0 ( sino es actuarial)
       param in nedamar    : Edad máx. ren
       param in ciedmar    : Edad Real
       param in nedmi2c    : Edad mín ctr 2º aseg.
       param in ciemi2c    : Edad real
       param in nedma2c    : Edad máx. ctr 2º aseg.
       param in ciema2c    : Edad Real
       param in nedma2r    : Edad máx. ren 2º aseg.
       param in ciema2r    : Real o Actuarial
       param in nsedmac    : Suma Máx. Edades
       param in cisemac    : Real
       param in cvinpol    : Póliza vinculada
       param in cvinpre    : Préstamo vinculado
       param in ccuesti    : Cuestionario Salud
       param in cctacor    : Libreta
       return              : 0 si ha ido bien
                            error si ha ido mal
   *************************************************************************/
   FUNCTION f_validagestion(
      psproduc IN NUMBER,
      pcduraci IN NUMBER,
      pctempor IN NUMBER,
      pndurcob IN NUMBER,
      pcdurmin IN NUMBER,
      pnvtomin IN NUMBER,
      pcdurmax IN NUMBER,
      pnvtomax IN NUMBER,
      pctipefe IN NUMBER,
      pnrenova IN NUMBER,
      pcmodnre IN NUMBER,
      pcprodcar IN NUMBER,
      pcrevali IN NUMBER,
      pprevali IN NUMBER,
      pirevali IN NUMBER,
      pctarman IN NUMBER,
      pcreaseg IN NUMBER,
      pcreteni IN NUMBER,
      pcprorra IN NUMBER,
      pcprimin IN NUMBER,
      piprimin IN NUMBER,
      pcclapri IN NUMBER,
      pipminfra IN NUMBER,
      pnedamic IN NUMBER,
      pciedmic IN NUMBER,
      pnedamac IN NUMBER,
      pciedmac IN NUMBER,
      pnedamar IN NUMBER,
      pciedmar IN NUMBER,
      pnedmi2c IN NUMBER,
      pciemi2c IN NUMBER,
      pnedma2c IN NUMBER,
      pciema2c IN NUMBER,
      pnedma2r IN NUMBER,
      pciema2r IN NUMBER,
      pnsedmac IN NUMBER,
      pcisemac IN NUMBER,
      pcvinpol IN NUMBER,
      pcvinpre IN NUMBER,
      pccuesti IN NUMBER,
      pcctacor IN NUMBER)
      RETURN NUMBER IS
      vc2cabezas     NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MNTPROD.F_ValidaGestion';
   BEGIN
      IF pcrevali IN(2, 6) THEN
         IF pprevali IS NULL THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'numerr: ' || 111399);
            RETURN 111399;
         END IF;
      ELSIF pcrevali = 1 THEN
         IF pirevali IS NULL THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'numerr: ' || 111399);
            RETURN 111399;
         END IF;
      END IF;

      vpasexec := 2;

      IF pcprimin = 0 THEN
         IF piprimin IS NULL THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'numerr: ' || 1000032);
            RETURN 1000032;   --PRIMA MÍNIMA ES NULA
         END IF;
      ELSIF pcprimin = 1 THEN
         IF pcclapri IS NULL THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'numerr: ' || 1000019);
            RETURN 1000019;   --FORMULA PRIMA MINIMA
         END IF;
      END IF;

      /*
      vpasexec := 3;

      begin
          select c2cabezas into vc2cabezas from productos where sproduc = psproduc;
          if vc2cabezas = 0 then
              if pnedmi2c is not null or pciemi2c is not null
                      or pnedma2c is not null or pciema2c is not null
                      or pnedma2r is not null or pciema2r is not null
                      or pnsedmac is not null or pcisemac is not null
                  then
                  p_tab_error (f_sysdate,f_user,vobject,vpasexec,vparam,'numerr: '||1000020);
                  RETURN 1000020; --EDADES MÁXIMAS O REALES INFORMADAS
              end if;
          end if;
      exception
      when others then
          p_tab_error (f_sysdate,f_user,vobject,vpasexec,vparam,'numerr: '||1000038);
                  RETURN 1000038; --NO EXISTE C2CABEZAS
      end;
      */ --CUANDO SE AÑADA EL C2CABEZAS SE DESCOMENTA
      IF pcctacor IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'numerr: ' || 1000037);
         RETURN 1000037;   --LIBRETA
      END IF;

      IF pcduraci IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'numerr: ' || 1000039);
         RETURN 1000039;   --TIPO DURACION
      END IF;

      IF pcmodnre IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'numerr: ' || 1000040);
         RETURN 1000040;   --INDICADOR FECHA RENOVACION MODIFICABLE EN CONTRATACION
      END IF;

      IF pctarman IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'numerr: ' || 1000041);
         RETURN 1000041;   --TARIFICACION PUEDE SER ANUAL
      END IF;

      IF pctempor IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'numerr: ' || 1000042);
         RETURN 1000042;   --ADMITE O NO POLIZAS TEMPORALES
      END IF;

      IF pctipefe IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'numerr: ' || 1000043);
         RETURN 1000043;   --TIPO DE EFECTO
      --BUG 9532 - 28/04/2009 - ICV - Si ctipefe = 1 controlar que informe nrenova
      ELSIF pctipefe = 1
            AND pnrenova IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'numerr: ' || 806314);
         RETURN 806314;   --DIAS DE RENOVACIÓN
      --FIN BUG 9532
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 111866;
   END f_validagestion;

   /*************************************************************************
       Graba los datos de gestión de un producto
       param in psproduc   : código del producto
       param in cduraci    : código de la duración
       param in ctempor    : Permite temporal
       param in ndurcob    : Duración pagos
       param in cdurmin    : Duración mínima
       param in nvtomin    : Tipo
       param in cdurmax    : duración máxima póliza
       param in nvtomax    : Número años máximo para el vto.
       param in ctipefe    : Tipo de efecto
       param in nrenova    : renovación
       param in cmodnre    : Fecha de renovación
       param in cprodcar   : Si ha pasado cartera
       param in crevali    : Código de revalorización
       param in prevali    : Porcentaje revalorización
       param in irevali    : Importe revalorización
       param in ctarman    : tarificación puede ser manual
       param in creaseg    : creaseg
       param in creteni    : Indicador de propuesta
       param in cprorra    : tipo prorrateo
       param in cprimin    : tipo de prima minima
       param in iprimin    : importe mínimo prima de recibo en emisión
       param in cclapri    : Fórmula prima mínima
       param in ipminfra   : Prima mínima fraccionada
       param in nedamic    : Edad mín ctr
       param in ciedmic    : Edad real
       param in nedamac    : Edad máx. ctr
       param in ciedmac    : Edad Real. Check por defecto = 0 ( sino es actuarial)
       param in nedamar    : Edad máx. ren
       param in ciedmar    : Edad Real
       param in nedmi2c    : Edad mín ctr 2º aseg.
       param in ciemi2c    : Edad real
       param in nedma2c    : Edad máx. ctr 2º aseg.
       param in ciema2c    : Edad Real
       param in nedma2r    : Edad máx. ren 2º aseg.
       param in ciema2r    : Real o Actuarial
       param in nsedmac    : Suma Máx. Edades
       param in cisemac    : Real
       param in cvinpol    : Póliza vinculada
       param in cvinpre    : Préstamo vinculado
       param in ccuesti    : Cuestionario Salud
       param in cctacor    : Libreta
       return              : 0 si ha ido bien
                            error si ha ido mal
   *************************************************************************/
   FUNCTION f_set_gestion(
      psproduc IN NUMBER,
      pcduraci IN NUMBER,
      pctempor IN NUMBER,
      pndurcob IN NUMBER,
      pcdurmin IN NUMBER,
      pnvtomin IN NUMBER,
      pcdurmax IN NUMBER,
      pnvtomax IN NUMBER,
      pctipefe IN NUMBER,
      pnrenova IN NUMBER,
      pcmodnre IN NUMBER,
      pcprodcar IN NUMBER,
      pcrevali IN NUMBER,
      pprevali IN NUMBER,
      pirevali IN NUMBER,
      pctarman IN NUMBER,
      pcreaseg IN NUMBER,
      pcreteni IN NUMBER,
      pcprorra IN NUMBER,
      pcprimin IN NUMBER,
      piprimin IN NUMBER,
      pcclapri IN NUMBER,
      pipminfra IN NUMBER,
      pnedamic IN NUMBER,
      pciedmic IN NUMBER,
      pnedamac IN NUMBER,
      pciedmac IN NUMBER,
      pnedamar IN NUMBER,
      pciedmar IN NUMBER,
      pnedmi2c IN NUMBER,
      pciemi2c IN NUMBER,
      pnedma2c IN NUMBER,
      pciema2c IN NUMBER,
      pnedma2r IN NUMBER,
      pciema2r IN NUMBER,
      pnsedmac IN NUMBER,
      pcisemac IN NUMBER,
      pcvinpol IN NUMBER,
      pcvinpre IN NUMBER,
      pccuesti IN NUMBER,
      pcctacor IN NUMBER,
      pcpreaviso IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MNTPROD.F_Set_Gestion';
      vcempres       NUMBER;
   BEGIN
      BEGIN
         UPDATE productos
            SET cduraci = pcduraci,
                ctempor = pctempor,
                ndurcob = pndurcob,
                cdurmin = pcdurmin,
                nvtomin = pnvtomin,
                cdurmax = pcdurmax,
                nvtomax = pnvtomax,
                ctipefe = pctipefe,
                nrenova = pnrenova,
                cmodnre = pcmodnre,
                crevali = pcrevali,
                prevali = pprevali,
                irevali = pirevali,
                ctarman = pctarman,
                creaseg = pcreaseg,
                creteni = pcreteni,
                cprorra = pcprorra,
                cprimin = pcprimin,
                iprimin = piprimin,
                cclapri = pcclapri,
                ipminfra = pipminfra,
                nedamic = pnedamic,
                ciedmic = pciedmic,
                nedamac = pnedamac,
                ciedmac = pciedmac,
                nedamar = pnedamar,
                ciedmar = pciedmar,
                nedmi2c = pnedmi2c,
                ciemi2c = pciemi2c,
                nedma2c = pnedma2c,
                ciema2c = pciema2c,
                nedma2r = pnedma2r,
                ciema2r = pciema2r,
                nsedmac = pnsedmac,
                cisemac = pcisemac,
                cvinpol = pcvinpol,
                cvinpre = pcvinpre,
                ccuesti = pccuesti,
                cctacor = pcctacor,
                cpreaviso = pcpreaviso
          WHERE sproduc = psproduc;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
            RETURN 103865;
      END;

      vpasexec := 3;

      -- Bug 30393/168070 - 05/05/2014 - AMC
      SELECT cempres
        INTO vcempres
        FROM codiram
       WHERE cramo IN(SELECT cramo
                        FROM productos
                       WHERE sproduc = psproduc);

      BEGIN
         IF pcprodcar = 0
            AND psproduc IS NOT NULL THEN
            -- Bug 30393/168070 - 05/05/2014 - AMC
            IF NVL(pac_parametros.f_parproducto_n(psproduc, 'CARTERA_DESCENTRAL'), 0) = 1 THEN
               DELETE      prodagecartera
                     WHERE sproduc = psproduc
                       AND cempres = vcempres
                       AND cagente = ff_agente_usuario(f_user);
            ELSE
               DELETE FROM prodcartera
                     WHERE sproduc = psproduc;
            END IF;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
            RETURN 108017;
      END;

      vpasexec := 5;

      BEGIN
         SELECT cempres
           INTO vcempres
           FROM codiram
          WHERE cramo IN(SELECT cramo
                           FROM productos
                          WHERE sproduc = psproduc);

         IF pcprodcar = 1
            AND psproduc IS NOT NULL THEN
            INSERT INTO prodcartera
                        (cempres, sproduc, fcarant, fcarpro, cramo, cmodali, ctipseg, ccolect,
                         fgenren)
               SELECT vcempres, sproduc, LAST_DAY(ADD_MONTHS(f_sysdate, -2)) + 1,
                      LAST_DAY(f_sysdate) + 1, cramo, cmodali, ctipseg, ccolect, NULL
                 FROM productos
                WHERE sproduc = psproduc;
         END IF;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            NULL;
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
            RETURN 108468;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 111866;
   END f_set_gestion;

   /*************************************************************************
      Realiza las validaciones de los datos de administración del producto
      param in pcempres    : código de la empresa.
      param in psproduc    : código del producto
      param in Pctipges    : Gestión del seguro.
      param in pcreccob    : 1er recibo
      param in pctipreb    : Recibo por.
      param in pccalcom    : Cálculo comisión
      param in pctippag    : Cobro
      param in pcmovdom    : Domiciliar el primer recibo
      param in pcfeccob    : Acepta fecha de cobro
      param in pcrecfra    : Recargo Fraccionamiento
      param in piminext    : Prima mínima extorno
      param in pndiaspro   : Días acumulables
      param in pcnv_spr    : Identificador del cliente para el producto en contabilidad
      retorna un cero si todo va bien  y un uno en caso contrario
   *************************************************************************/
   FUNCTION f_valida_admprod(
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pctipges IN NUMBER,
      pcreccob IN NUMBER,
      pctipreb IN NUMBER,
      pccalcom IN NUMBER,
      pctippag IN NUMBER,
      pcmovdom IN NUMBER,
      pcfeccob IN NUMBER,
      pcrecfra IN NUMBER,
      piminext IN NUMBER,
      pndiaspro IN NUMBER,
      pcnv_spr IN VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := ' pcempres: ' || pcempres || ' ,sproduc:' || psproduc || ' ,ctipges:' || pctipges
            || ' ,creccob:' || pcreccob || ' ,ctipreb: ' || pctipreb || ' ,ccalcom:'
            || pccalcom || ' ,ctippag:' || pctippag || ' ,cmovdom:' || pcmovdom
            || ' ,cfeccob:' || pcfeccob || ' ,crecfra:' || pcrecfra || ' ,iminext:'
            || piminext || ' ,ndiaspro:' || pndiaspro || ' cnv_spr:' || pcnv_spr;
      vobject        VARCHAR2(200) := 'PAC_MNTPROD.F_Valida_AdmProd';
      nerror         NUMBER := 0;
   BEGIN
      /*
      Valida que el campo creccob solo este informado si la función ff_es_correduria = 1
      A parte ha de validar que los siguientes campos han de estar informados:
      sproduc. Código del producto. Parámetro de entrada
      pcreccob. 1er recibo. Parámetro de entrada
      pctipreb. Recibo por. Parámetro de entrada
      pctippag. Cobro. Parámetro de entrada
      pcrecfra. Recargo Fraccionamiento. Parámetro de entrada
      */
      --Comprovació dels paràmetres d'entrada
      IF pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcreccob IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pctipreb IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pctippag IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcrecfra IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      IF pcreccob IS NOT NULL THEN
         vpasexec := 5;
         nerror := ff_es_correduria(pcempres);

         IF nerror <> 1 THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, nerror);
            RETURN nerror;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, NULL);
         RETURN 103835;   --Campo no puede ser nulo
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 110080;   --Error al insertar en productos
   END f_valida_admprod;

   /*************************************************************************
      Realiza las  modificaciones de los datos de administración del producto
      param in psproduc    : código del producto
      param in Pctipges    : Gestión del seguro.
      param in pcreccob    : 1er recibo
      param in pctipreb    : Recibo por.
      param in pccalcom    : Cálculo comisión
      param in pctippag    : Cobro
      param in pcmovdom    : Domiciliar el primer recibo
      param in pcfeccob    : Acepta fecha de cobro
      param in pcrecfra    : Recargo Fraccionamiento
      param in piminext    : Prima mínima extorno
      param in pndiaspro   : Días acumulables
      param in pcnv_spr    : Identificador del cliente para el producto en contabilidad
      param out mensajes   : mensajes de error
      retorna un cero si todo va bien  y un uno en caso contrario
   *************************************************************************/
   FUNCTION f_set_admprod(
      psproduc IN NUMBER,
      pctipges IN NUMBER,
      pcreccob IN NUMBER,
      pctipreb IN NUMBER,
      pccalcom IN NUMBER,
      pctippag IN NUMBER,
      pcmovdom IN NUMBER,
      pcfeccob IN NUMBER,
      pcrecfra IN NUMBER,
      piminext IN NUMBER,
      pndiaspro IN NUMBER,
      pcnv_spr IN VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := ' sproduc:' || psproduc || ' ,ctipges:' || pctipges || ' ,creccob:' || pcreccob
            || ' ,ctipreb:' || pctipreb || ' ,ccalcom:' || pccalcom || ' ,ctippag:'
            || pctippag || ' ,cmovdom:' || pcmovdom || ' ,cfeccob:' || pcfeccob
            || ' ,crecfra:' || pcrecfra || ' ,iminext:' || piminext || ' ,ndiaspro:'
            || pndiaspro || ' cnv_spr:' || pcnv_spr;
      vobject        VARCHAR2(200) := 'PAC_MNTPROD.F_Set_AdmProd';
      nerror         NUMBER := 0;
   BEGIN
      --Comprovació dels paràmetres d'entrada
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      UPDATE productos
         SET ctipges = pctipges,   -- . Gestión del seguro. Parámetro de entrada
             creccob = pcreccob,   -- . 1er recibo. Parámetro de entrada
             ctipreb = pctipreb,   -- . Recibo por. Parámetro de entrada
             ccalcom = pccalcom,   -- . Cálculo comisión. Parámetro de entrada
             ctippag = pctippag,   -- . Cobro. Parámetro de entrada
             cmovdom = pcmovdom,   -- . Domiciliar el primer recibo. Parámetro de entrada
             cfeccob = pcfeccob,   -- . Acepta fecha de cobro. Parámetro de entrada
             crecfra = pcrecfra,   -- . Recargo Fraccionamiento. Parámetro de entrada
             iminext = piminext,   -- . Prima mínima extorno. Parámetro de entrada
             ndiaspro = pndiaspro   -- . Días acumulables. Parámetro de entrada
       WHERE sproduc = psproduc;

      vpasexec := 4;

      -- Bug 32367 - 25/09/2014 - JTT: Actualizamos el codigo del producto contable del cliente.
      IF pcnv_spr IS NOT NULL THEN
         BEGIN
            INSERT INTO cnvproductos_ext
                        (sproduc, cnv_spr)
                 VALUES (psproduc, pcnv_spr);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE cnvproductos_ext
                  SET cnv_spr = pcnv_spr
                WHERE sproduc = psproduc;
         END;
      ELSE
         DELETE FROM cnvproductos_ext
               WHERE sproduc = psproduc;
      END IF;

      RETURN nerror;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, NULL);
         RETURN 103835;   --Campo no puede ser nulo
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 110080;   --Error al insertar en productos
   END f_set_admprod;

   /*************************************************************************
      Valida la forma de pago
      param in psproduc   : código del producto
      param in pcforpag   : código de la forma de pago
      param in pcobliga   : código de obligatoriedad
      param in pprecarg   : código precarg
      param in pcpagdef   : código pago por defecto
      param in pcrevfpg   : código revfpg
      return              : 0 si ha ido bien
                            numero error si ha ido mal
   *************************************************************************/
   FUNCTION f_validaforpago(
      psproduc IN NUMBER,
      pcforpag IN NUMBER,
      pcobliga IN NUMBER,
      pprecarg IN NUMBER,
      pcpagdef IN NUMBER,
      pcrevfpg IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc || ' pcforpag=' || pcforpag;
      vobject        VARCHAR2(200) := 'PAC_MNTPROD.F_ValidaForpago';
   BEGIN
      IF pcobliga = 0 THEN
         IF NVL(pprecarg, 0) <> 0
            OR NVL(pcpagdef, 0) <> 0 THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'numerr: ' || 1000036);
            RETURN 1000036;   --EL CAMPO PRECARG Y EL CPAGDEF NO PUEDEN ESTAR INFORMADOS
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 111866;
   END f_validaforpago;

   /*************************************************************************
      Modifica las forma de pago de un producto
      param in psproduc   : código del producto
      param in pcforpag   : código de la forma de pago
      param in pcobliga   : código de obligatoriedad
      param in pprecarg   : código precarg
      param in pcpagdef   : código pago por defecto
      param in pcrevfpg   : código revfpg
      return              : 0 si ha ido bien
                            numero error si ha ido mal
   *************************************************************************/
   FUNCTION f_setforpago(
      psproduc IN NUMBER,
      pcforpag IN NUMBER,
      pcobliga IN NUMBER,
      pprecarg IN NUMBER,
      pcpagdef IN NUMBER,
      pcrevfpg IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc || ' pcforpag=' || pcforpag;
      vobject        VARCHAR2(200) := 'PAC_MNTPROD.F_SetForpago';
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
   BEGIN
      IF psproduc IS NULL
         OR pcforpag IS NULL THEN
         RETURN 110721;
      END IF;

      vpasexec := 3;

      SELECT cramo, cmodali, ctipseg, ccolect
        INTO vcramo, vcmodali, vctipseg, vccolect
        FROM productos
       WHERE sproduc = psproduc;

      UPDATE productos
         SET cpagdef = DECODE(pcpagdef, 1, pcforpag, cpagdef),
             crevfpg = DECODE(pcforpag, 0, pcrevfpg, crevfpg)
       WHERE sproduc = psproduc;

      vpasexec := 5;

      IF pcobliga = 0 THEN   -- No se permite la forma de pago
         DELETE FROM forpagpro
               WHERE cramo = vcramo
                 AND cmodali = vcmodali
                 AND ctipseg = vctipseg
                 AND ccolect = vccolect
                 AND cforpag = pcforpag;

         --Miramos a ver si además  está informado el recargo
         /*IF pprecarg IS NOT NULL THEN
            -- Si viene informado lo borramos, ya que la forma de pago no tiene recargo para este producto en concreto.
            DELETE FROM forpagrecprod
                  WHERE cramo = vcramo
                    AND cmodali = vcmodali
                    AND ctipseg = vctipseg
                    AND ccolect = vccolect
                    AND cforpag = pcforpag;
         END IF;*/

         -- Miramos si la renovación está informada sin estar la forma de pago marcada
         UPDATE productos
            SET crevfpg = 0
          WHERE sproduc = psproduc;
      ELSE
         -- Insertamos en la tabla de las formas de pago
         BEGIN
            INSERT INTO forpagpro
                        (cramo, cmodali, ctipseg, ccolect, cforpag)
                 VALUES (vcramo, vcmodali, vctipseg, vccolect, pcforpag);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               NULL;
         END;

         vpasexec := 7;
      -- Si todo va bien insertamos el recargo por forma de pago si viene informado.
      /*IF pprecarg IS NULL THEN
         -- Si no viene informado lo borramos, ya que la forma de pago no tiene recargo para este producto en concreto.
         DELETE FROM forpagrecprod
               WHERE cramo = vcramo
                 AND cmodali = vcmodali
                 AND ctipseg = vctipseg
                 AND ccolect = vccolect
                 AND cforpag = pcforpag;
      ELSE
         vpasexec := 9;

         BEGIN
            INSERT INTO forpagrecprod
                        (cramo, cmodali, ctipseg, ccolect, cforpag, precarg)
                 VALUES (vcramo, vcmodali, vctipseg, vccolect, pcforpag, pprecarg);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               BEGIN
                  -- Si ya estaba... pues modificamos el porcentaje por si ha cambiado.
                  UPDATE forpagrecprod
                     SET precarg = pprecarg
                   WHERE cramo = vcramo
                     AND cmodali = vcmodali
                     AND ctipseg = vctipseg
                     AND ccolect = vccolect
                     AND cforpag = pcforpag;
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 110721;
               END;
         END;
      END IF;*/
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 110721;
   END f_setforpago;

   /*************************************************************************
      Inserta o modifica los impuestos de una garantia
      param in psproduc    : código del producto
      param in pcactivi    : código de la actividad
      param in pcgarant    : código de la garantía
      param in pcimpcon    : aplica consorcio 0/1
      param in pcimpdgs    : aplica la DGS 0/1
      param in pcimpips    : aplica IPS 0/1
      param in pcimparb    : se calcula arbitrios 0/1
      param in pcimpfng    :
      param out mensajes   : mensajes de error
      return               : 0 si ha ido bien
                            numero error si ha ido mal
   *************************************************************************/
   FUNCTION f_set_impuestosgaran(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcimpcon IN NUMBER,
      pcimpdgs IN NUMBER,
      pcimpips IN NUMBER,
      pcimparb IN NUMBER,
      pcimpfng IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := 'psproduc=' || psproduc || ' pcactivi=' || pcactivi || ' pcgarant=' || pcgarant
            || ' pcimpcon=' || pcimpcon || ' pcimpdgs=' || pcimpdgs || ' pcimpips='
            || pcimpips || ' pcimparb=' || pcimparb || 'pcimpfng=' || pcimpfng;
      vobject        VARCHAR2(200) := 'PAC_MNTPROD.F_Set_ImpuestosGaran';
      vpsproduc      NUMBER;
      nerror         NUMBER := 0;
   BEGIN
      UPDATE garanpro
         SET cimpcon = pcimpcon,
             cimpdgs = pcimpdgs,
             cimpips = pcimpips,
             cimparb = pcimparb,
             cimpfng = pcimpfng
       WHERE sproduc = psproduc
         AND cgarant = pcgarant
         AND cactivi = pcactivi;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 102428;
   END f_set_impuestosgaran;

   /*************************************************************************
       Inserta o modifica la formula de una garantia
       param in Psproduc      : código del producto
       param in Pcactivi    : código de la actividad
       param in Pcgarant    : código de la garantía
       param in Pccampo    : código del campo
       param in Pclave    : clave fórmula
       return               : 0 si ha ido bien
                             numero error si ha ido mal
   *************************************************************************/
   FUNCTION f_set_prodgarformulas(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pccampo IN VARCHAR2,
      pclave IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := 'psproduc=' || psproduc || ' pcactivi=' || pcactivi || ' pcgarant=' || pcgarant
            || ' pccampo=' || pccampo || ' pclave=' || pclave;
      vobject        VARCHAR2(200) := 'PAC_MNTPROD.F_Set_ProdGarFormulas';
      xcramo         NUMBER;
      xcmodali       NUMBER;
      xctipseg       NUMBER;
      xccolect       NUMBER;
   BEGIN
      IF psproduc IS NULL
         OR pcactivi IS NULL
         OR pcgarant IS NULL
         OR pccampo IS NULL
         OR pclave IS NULL THEN
         RETURN 110087;
      END IF;

      vpasexec := 3;

      SELECT cramo, cmodali, ctipseg, ccolect
        INTO xcramo, xcmodali, xctipseg, xccolect
        FROM productos
       WHERE sproduc = psproduc;

      INSERT INTO garanformula
                  (cgarant, ccampo, cramo, cmodali, ctipseg, ccolect, cactivi, clave)
           VALUES (pcgarant, pccampo, xcramo, xcmodali, xctipseg, xccolect, pcactivi, pclave);

      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         BEGIN
            vpasexec := 7;

            UPDATE garanformula
               SET clave = pclave
             WHERE cramo = xcramo
               AND cmodali = xcmodali
               AND ctipseg = xctipseg
               AND ccolect = xccolect
               AND cgarant = pcgarant
               AND cactivi = pcactivi
               AND ccampo = pccampo;

            RETURN 0;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN 110087;
         END;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 110087;
   END f_set_prodgarformulas;

/*************************************************************************
    Función que validará los datos técnicos de un producto en concreto
    PARAM IN Psproduc: Código del producto
    PARAM IN pnniggar: Indicar de si los gastos están a nivel de garantía
    PARAM IN pnniigar: Indicador de si el interés técnico está a nivel de garantía
    PARAM IN pcmodint: Intereses tecnicos modificables en póliza.
    PARAM IN pcintrev: Por defecto en renovación aplicar el interés del producto
    PARAM IN pncodint: Código del cuadro de interés que se ha escogido para el producto
    RETURN  :0 si todo ha ido bien,número de error en caso contrario
*************************************************************************/
   FUNCTION f_validadattecn(
      psproduc IN NUMBER,
      pnniggar IN NUMBER,
      pnniigar IN NUMBER,
      pcmodint IN NUMBER,
      pcintrev IN NUMBER,
      pncodint IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      NULL;
      RETURN 0;
   END f_validadattecn;

       /*************************************************************************
       Función que modificará los datos técnicos de un producto en concreto
       PARAM IN Psproduc: Código del producto. Parámetro de entrada
       PARAM IN pnniggar: Indicar de si los gastos están a nivel de garantía Parámetro de entrada
       PARAM IN pnniigar: Indicador de si el interés técnico está a nivel de garantía. Parámetro de entrada
       PARAM IN pcmodint: Intereses tecnicos modificables en póliza.
       PARAM IN pcintrev: Por defecto en renovación aplicar el interés del producto
       PARAM IN pncodint: Código del cuadro de interés que se ha escogido para el producto
       RETURN  :0 si todo ha ido bien,número de error en caso contrario
   *************************************************************************/
   FUNCTION f_set_dattecn(
      psproduc IN NUMBER,
      pnniggar IN NUMBER,
      pnniigar IN NUMBER,
      pcmodint IN NUMBER,
      pcintrev IN NUMBER,
      pncodint IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := 'psproduc=' || psproduc || ' PNNIGGAR=' || pnniggar || ' PNNIIGAR=' || pnniigar
            || ' PCMODINT=' || pcmodint || ' PCINTREV=' || pcintrev || ' PNCODINT='
            || pncodint;
      vobject        VARCHAR2(200) := 'PAC_MNTPROD.F_Set_DatTecn';
   BEGIN
      UPDATE productos
         SET nniggar = pnniggar,
             nniigar = pnniigar,
             cmodint = pcmodint,
             cintrev = pcintrev
       --  Ncodint = pncodint
      WHERE  sproduc = psproduc;

      IF pncodint IS NULL THEN
         DELETE FROM intertecprod
               WHERE sproduc = psproduc;
      ELSE
         BEGIN
            INSERT INTO intertecprod
                        (sproduc, ncodint)
                 VALUES (psproduc, pncodint);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE intertecprod
                  SET ncodint = pncodint
                WHERE sproduc = psproduc;
         END;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1000444;
   END f_set_dattecn;

   /*************************************************************************
       Función que se encargará de borrar un cuadro de interés técnico
       PARAM IN PNCODINT  : Código del cuadro de interés
   *************************************************************************/
   FUNCTION f_del_intertec(pncodint IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400) := 'PNCODINT=' || pncodint;
      vobject        VARCHAR2(200) := 'PAC_MNTPROD.F_DEL_INTERTEC';
      num_err        NUMBER;
      interprod      NUMBER;
      intergar       NUMBER;
   BEGIN
      SELECT COUNT(1)
        INTO interprod
        FROM intertecprod
       WHERE ncodint = pncodint;

      IF interprod > 0 THEN
         RETURN 1000545;
      END IF;

      SELECT COUNT(1)
        INTO intergar
        FROM intertecgar
       WHERE ncodint = pncodint;

      IF intergar > 0 THEN
         RETURN 1000546;
      END IF;

      -- Borramos la descripción por idiomas de un cuadro
      DELETE FROM detintertec
            WHERE ncodint = pncodint;

      -- Borramos el código del cuadro
      DELETE FROM codintertec
            WHERE ncodint = pncodint;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         IF SQLCODE = -2292 THEN
            RETURN 1000445;
         ELSE
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
            RETURN 1000446;
         END IF;
   END f_del_intertec;

    /*************************************************************************
        Función que se encargará de borrar una vigencia de un cuadro de interés técnico
        PARAM IN PNCODINT  : Código del cuadro de interés
        PARAM IN PCTIPO    : Código del tipo de interés.
        PARAM IN PFINICIO  : Fecha inicio vigencia del tramo.
        PARAM OUT mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_del_intertecmov(pncodint IN NUMBER, pctipo IN NUMBER, pfinicio IN DATE)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400) := 'PNCODINT=' || pncodint;
      vobject        VARCHAR2(200) := 'PAC_MNTPROD.f_del_intertecmov';
   BEGIN
      -- Borramos una vigencia en concreto.
      -- Esta función solo borrar la vigencia anterior queda cerrada, el usuario
      -- manualmente debe volver a abrirla.
      DELETE FROM intertecmov
            WHERE ncodint = pncodint
              AND ctipo = pctipo
              AND finicio = pfinicio;

      -- Bug 16002 - 15/09/2010 - AMC
      UPDATE intertecmov
         SET ffin = NULL
       WHERE ncodint = pncodint
         AND ctipo = pctipo
         AND ffin = pfinicio - 1;

      -- Fi Bug 16002 - 15/09/2010 - AMC
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         IF SQLCODE = -2292 THEN
            RETURN 1000447;
         ELSE
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
            RETURN 1000446;
         END IF;
   END f_del_intertecmov;

    /*************************************************************************
        Función que se encargará de borrar una vigencia de un cuadro de interés técnico
        PARAM IN PNCODINT  : Código del cuadro de interés
        PARAM IN PCTIPO    : Código del tipo de interés.
        PARAM IN PFINICIO  : Fecha inicio vigencia del tramo.
        PARAM IN PNDESDE   : importe/edad desde
        PARAM OUT mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_del_intertecmovdet(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      pfinicio IN DATE,
      pndesde IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := 'PNCODINT=' || pncodint || ' PCTIPO =' || pctipo || ' PNDESDE = ' || pndesde
            || ' PFINICIO = ' || pfinicio;
      vobject        VARCHAR2(200) := 'PAC_MNTPROD.f_del_intertecmovdet';
   BEGIN
      -- Borramos un tramo en concreto.
      DELETE FROM intertecmovdet
            WHERE ncodint = pncodint
              AND ctipo = pctipo
              AND ndesde = pndesde
              AND finicio = pfinicio;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         IF SQLCODE = -2292 THEN
            RETURN 108017;
         ELSE
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
            RETURN 1000446;
         END IF;
   END f_del_intertecmovdet;

    /*************************************************************************
        Función que validará la inserción o modificación de una vigencia
        PARAM IN PNCODINT  : Código del cuadro de interés
        PARAM IN PCTIPO    : Código del tipo de interés.
        PARAM IN PFINICIO  : Fecha inicio vigencia del tramo.
        PARAM IN PFFIN     : Fecha fin vigencia del tramo.
        PARAM IN PCTRAMTIP : Concepto del tramo
   *************************************************************************/
   FUNCTION f_valida_intertecmov(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      pfinicio IN DATE,
      pffin IN DATE,
      pctramtip IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := 'PNCODINT=' || pncodint || ' PCTIPO=' || pctipo || ' PFINICIO=' || pfinicio
            || ' PFFIN=' || pffin || ' PCTRAMTIP=' || pctramtip;
      vobject        VARCHAR2(200) := 'PAC_MNTPROD.F_valida_Intertecmov';
      vffin          DATE;
   BEGIN
      IF pncodint IS NULL
         OR pctipo IS NULL
         OR pfinicio IS NULL
         OR pctramtip IS NULL THEN
         RETURN 103135;
      END IF;

      IF pffin IS NULL THEN
         SELECT MAX(ffin)
           INTO vffin
           FROM intertecmov
          WHERE ncodint = pncodint
            AND ctipo = pctipo
            AND ctramtip = pctramtip;

         IF pfinicio <= vffin THEN
            RETURN 1000450;
         END IF;
      ELSE
         IF pffin < pfinicio THEN
            RETURN 1000451;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1000452;
   END f_valida_intertecmov;

/*************************************************************************
        Función que insertar o modifica los valores de una vigencia para un cuadro de interes
        PARAM IN PNCODINT  : Código del cuadro de interés
        PARAM IN PCTIPO    : Código del tipo de interés.
        PARAM IN PFINICIO  : Fecha inicio vigencia del tramo.
        PARAM IN PFFIN     : Fecha fin vigencia del tramo.
        PARAM IN PCTRAMTIP : Concepto del tramo
   *************************************************************************/
   FUNCTION f_set_intertecmov(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      pfinicio IN DATE,
      pffin IN DATE,
      pctramtip IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := 'PNCODINT=' || pncodint || ' PCTIPO=' || pctipo || ' PFINICIO=' || pfinicio
            || ' PFFIN=' || pffin || ' PCTRAMTIP=' || pctramtip;
      vobject        VARCHAR2(200) := 'PAC_MNTPROD.F_valida_Intertecmov';
   BEGIN
      -- Bug 16002 - 15/09/2010 - AMC
      UPDATE intertecmov
         SET ffin = pfinicio - 1
       WHERE ncodint = pncodint
         AND ctipo = pctipo
         AND ffin IS NULL;

      -- Fi Bug 16002 - 15/09/2010 - AMC
      INSERT INTO intertecmov
                  (ncodint, finicio, ctipo, ffin, ctramtip)
           VALUES (pncodint, pfinicio, pctipo, pffin, pctramtip);

      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         UPDATE intertecmov
            SET ffin = pffin
          WHERE ncodint = pncodint
            AND ctipo = pctipo
            AND finicio = pfinicio;

         RETURN 0;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1000453;
   END f_set_intertecmov;

    /*************************************************************************
        Función que valida los datos de un tramo de interes.
        PARAM IN PNCODINT : Código del cuadro de interés
        PARAM IN PCTIPO   : Código del tipo de interés
        PARAM IN PFINICIO : Fecha inicio vigencia del tramo
        PARAM IN PNDESDE  : Importe/Edad Desde
        PARAM IN PNHASTA  : Importe/Edad Hasta
        PARAM IN PNINTTEC : Porcentaje
   *************************************************************************/
   FUNCTION f_valida_intertecmovdet(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      pfinicio IN DATE,
      pndesde IN NUMBER,
      pnhasta IN NUMBER,
      pninttec IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := 'PNCODINT=' || pncodint || ' PCTIPO=' || pctipo || ' PFINICIO=' || pfinicio
            || ' PNDESDE=' || pndesde || ' PNHASTA=' || pnhasta || ' PNINTTEC=' || pninttec;
      vobject        VARCHAR2(200) := 'PAC_MNTPROD.F_Valida_intertecmovdet';
      vndesde        NUMBER;
      vnhasta        NUMBER;
      vmayor         NUMBER;
   BEGIN
      -- Miramos los campos obligatorios
      IF pncodint IS NULL
         OR pctipo IS NULL
         OR pfinicio IS NULL
         OR pndesde IS NULL
         OR pninttec IS NULL THEN
         RETURN 103135;
      END IF;

      IF pnhasta IS NOT NULL THEN
         IF pnhasta < pndesde THEN
            RETURN 1000454;
         END IF;
      ELSE
         --Miramos si se produce solapamiento entre tramos
         SELECT MAX(ndesde), MAX(nhasta)
           INTO vndesde, vnhasta
           FROM intertecmovdet
          WHERE ncodint = pncodint
            AND ctipo = pctipo
            AND finicio = pfinicio;

         IF vndesde > vnhasta THEN
            vmayor := vndesde;
         ELSE
            vmayor := vnhasta;
         END IF;

         IF pndesde < vmayor THEN
            RETURN 1000454;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1000455;
   END f_valida_intertecmovdet;

/*************************************************************************
        Función que INSERTA/MODIFICA los datos de un tramo de interes.
        PARAM IN PNCODINT : Código del cuadro de interés
        PARAM IN PCTIPO   : Código del tipo de interés
        PARAM IN PFINICIO : Fecha inicio vigencia del tramo
        PARAM IN PNDESDE  : Importe/Edad Desde
        PARAM IN PNHASTA  : Importe/Edad Hasta
        PARAM IN PNINTTEC : Porcentaje
   *************************************************************************/
   FUNCTION f_set_intertecmovdet(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      pfinicio IN DATE,
      pndesde IN NUMBER,
      pnhasta IN NUMBER,
      pninttec IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := 'PNCODINT=' || pncodint || ' PCTIPO=' || pctipo || ' PFINICIO=' || pfinicio
            || ' PNDESDE=' || pndesde || ' PNHASTA=' || pnhasta || ' PNINTTEC=' || pninttec;
      vobject        VARCHAR2(200) := 'PAC_MNTPROD.F_set_intertecmovdet';
   BEGIN
      INSERT INTO intertecmovdet
                  (ncodint, finicio, ctipo, ndesde, nhasta, ninttec)
           VALUES (pncodint, pfinicio, pctipo, pndesde, pnhasta, pninttec);

      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         UPDATE intertecmovdet
            SET nhasta = pnhasta,
                ninttec = pninttec
          WHERE ncodint = pncodint
            AND finicio = pfinicio
            AND ctipo = pctipo
            AND ndesde = pndesde;

         RETURN 0;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1000455;
   END f_set_intertecmovdet;

   /*******BUG8510-29/12/2008-XCG Afegir funcions*********/
   /*************************************************************************
          Función que INSERTA las actividades seleccionadas previamente.
          PARAM IN PCRAMO   : Código del Ramo del producto
          PARAM IN PCMODALI : Código de la Modalidad del producto
          PARAM IN PCTIPSEG : Código del tipo de Seguro del producto
          PARAM IN PCCOLECT : Código del la Colectividad del producto
          PARAM IN PSPRODUC : Código del Identificador del producto
          PARAM IN PCACTIVI : Código de la Actividad
          RETURN NUMBER     : número de error (0: operación correcta sino num error)
   *************************************************************************/
   FUNCTION f_set_actividades(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MNTROP.F_set_actividades';
   BEGIN
      INSERT INTO activiprod
                  (cmodali, ccolect, ctipseg, cactivi, cramo)
           VALUES (pcmodali, pccolect, pctipseg, pcactivi, pcramo);

      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         p_tab_error(f_sysdate, f_user, vobjectname, 0, 'valores duplicados tabla ACTIVIPROD',
                     SQLERRM || ' ' || SQLCODE);
         RETURN 101142;   --Error al insertar en la tabla ACTIVISEGU
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, 1, 'error inserción tabla ACTIVIPROD',
                     SQLERRM || ' ' || SQLCODE);
         RETURN 101142;   --Error al insertar en la tabla ACTIVISEGU
   END f_set_actividades;

/*************************************************************************
        Función que retorna un objeto con el recargo del fraccionamiento asignado a una actividad de producto.
        PARAM IN PCRAMO      : Código del Ramo del producto
        PARAM IN PCMODALI    : Código de la Modalidad del producto
        PARAM IN PCTIPSEG    : Código del tipo de Seguro del producto
        PARAM IN PCCOLECT    : Código del la Colectividad del producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM IN PCIDIOMA    : Código del Idioma
        PARAM OUT PRETCURSOR : SYS_REFCURSOR
        RETURN NUMBER        : número de error (0: operación correcta sino num error)
   *************************************************************************/
   FUNCTION f_get_recactividad(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcidioma IN NUMBER,
      pretcursor IN OUT sys_refcursor)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MNTROP.F_get_reactividad';
   BEGIN
      OPEN pretcursor FOR
         SELECT cforpag, d.tatribu, precarg
           FROM forpagrecacti fp, detvalores d
          WHERE fp.cramo = pcramo
            AND fp.cmodali = pcmodali
            AND fp.ctipseg = pctipseg
            AND fp.ccolect = pccolect
            AND fp.sproduc = psproduc
            AND fp.cactivi = pcactivi
            AND d.cidioma = pcidioma
            AND d.cvalor = 17
            AND d.catribu = fp.cforpag;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         IF pretcursor%ISOPEN THEN
            CLOSE pretcursor;
         END IF;

         p_tab_error(f_sysdate, f_user, vobjectname, 0, 'OTHERS cursor',
                     SQLERRM || ' ' || SQLCODE);
         RETURN 110722;   /*Error al inserir a la taula FORPAGRECACTI*/
   END f_get_recactividad;

/*************************************************************************
        Función que retorna un objeto con las preguntas definidas a nivel de una actividad de producto.
        PARAM IN PCRAMO      : Código del Ramo del producto
        PARAM IN PCMODALI    : Código de la Modalidad del producto
        PARAM IN PCTIPSEG    : Código del tipo de Seguro del producto
        PARAM IN PCCOLECT    : Código del la Colectividad del producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM IN PCIDIOMA    : Código del Idioma
        PARAM OUT PRETCURSOR : SYS_REFCURSOR
        RETURN NUMBER        : número de error (0: operación correcta sino num error)
   *************************************************************************/
   FUNCTION f_get_pregactividad(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcidioma IN NUMBER,
      pretcursor IN OUT sys_refcursor)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MNTROP.F_get_pregactividad';
   BEGIN
      OPEN pretcursor FOR
         SELECT pa.cpregun, pr.tpregun, pa.cpretip, NULL tpretip, pa.cpreobl, pa.tprefor,
                pa.tvalfor, pa.cresdef, NULL tresdef, pa.cofersn, pa.npreimp
           FROM pregunproactivi pa, preguntas pr
          WHERE pa.cramo = pcramo
            AND pa.cmodali = pcmodali
            AND pa.ctipseg = pctipseg
            AND pa.ccolect = pccolect
            AND pa.cactivi = pcactivi
            AND pr.cpregun = pa.cpregun
            AND pr.cidioma = pcidioma;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         IF pretcursor%ISOPEN THEN
            CLOSE pretcursor;
         END IF;

         p_tab_error(f_sysdate, f_user, vobjectname, 0, 'OTHERS cursor',
                     SQLERRM || ' ' || SQLCODE);
         RETURN 151021;   /*Error a l'inserir a la taula PREGUNPROACTIVI*/
   END f_get_pregactividad;

/*************************************************************************
        Función que retorna un objeto con las actividades de un producto.
        PARAM IN PCRAMO      : Código del Ramo del producto
        PARAM IN PCMODALI    : Código de la Modalidad del producto
        PARAM IN PCTIPSEG    : Código del tipo de Seguro del producto
        PARAM IN PCCOLECT    : Código del la Colectividad del producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM IN PCIDIOMA    : Código del Idioma
        PARAM OUT PRETCURSOR : SYS_REFCURSOR
        RETURN NUMBER        : número de error (0: operación correcta sino num error)
   *************************************************************************/
   FUNCTION f_get_actividades(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcidioma IN NUMBER,
      pretcursor IN OUT sys_refcursor)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MNTROP.F_get_actividades';
   BEGIN
      OPEN pretcursor FOR
         SELECT   activisegu.cactivi, activisegu.tactivi
             FROM activiprod INNER JOIN activisegu
                  ON activiprod.cactivi = activisegu.cactivi
                AND activiprod.cramo = activisegu.cramo
            WHERE activiprod.cramo = pcramo
              AND activiprod.cmodali = pcmodali
              AND activiprod.ctipseg = pctipseg
              AND activiprod.ccolect = pccolect
              AND activisegu.cidioma = pcidioma
         ORDER BY activisegu.cactivi;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         IF pretcursor%ISOPEN THEN
            CLOSE pretcursor;
         END IF;

         p_tab_error(f_sysdate, f_user, vobjectname, 0, 'OTHERS cursor',
                     SQLERRM || ' ' || SQLCODE);
         RETURN 103485;   /*Error al insertar en la tabla ACTIVIPROD*/
   END f_get_actividades;

/*************************************************************************
        Función que inserta datos de la forma de pago y recargo por actividad.
        PARAM IN PCRAMO      : Código del Ramo del producto
        PARAM IN PCMODALI    : Código de la Modalidad del producto
        PARAM IN PCTIPSEG    : Código del tipo de Seguro del producto
        PARAM IN PCCOLECT    : Código del la Colectividad del producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM IN PCFORPAG    : Código de la forma de pago
        PARAM IN PPRECARG    : Porcentage del recargo
        PARAM OUT NERROR     : Código de error
        RETURN NUMBER        : número de error (0: operación correcta sino 1)
   *************************************************************************/
   FUNCTION f_set_recactividad(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcforpag IN NUMBER,
      pprecarg IN NUMBER,
      nerror OUT NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MNTROP.F_set_reactividad';
      vtotal         NUMBER := 0;
   BEGIN
      SELECT COUNT(*)
        INTO vtotal
        FROM forpagrecprod
       WHERE ctipseg = pctipseg
         AND cramo = pcramo
         AND cmodali = pcmodali
         AND cforpag = pcforpag
         AND ccolect = pccolect
         AND precarg = pprecarg;

      IF vtotal > 0
         OR pprecarg IS NULL THEN
         BEGIN
            DELETE FROM forpagrecacti
                  WHERE cramo = pcramo
                    AND cmodali = pcmodali
                    AND ctipseg = pctipseg
                    AND ccolect = pccolect
                    AND cactivi = pcactivi
                    AND cforpag = pcforpag;

            nerror := 0;
            RETURN 0;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, vobjectname, 0,
                           'ERROR A L''ESBORRAR FORPAGRECACTI', SQLERRM || ' ' || SQLCODE);
               nerror := 112103;   /*Error al borrar la taula FORPAGRECACTI*/
               RETURN 1;
         END;
      ELSIF pprecarg IS NOT NULL
            AND vtotal = 0 THEN
         BEGIN
            INSERT INTO forpagrecacti
                        (cramo, cmodali, ccolect, ctipseg, sproduc, cactivi, cforpag,
                         precarg)
                 VALUES (pcramo, pcmodali, pccolect, pctipseg, psproduc, pcactivi, pcforpag,
                         pprecarg);

            nerror := 0;
            RETURN 0;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               BEGIN
                  UPDATE forpagrecacti
                     SET cramo = pcramo,
                         cmodali = pcmodali,
                         ccolect = pccolect,
                         ctipseg = pctipseg,
                         sproduc = psproduc,
                         cactivi = pcactivi,
                         cforpag = pcforpag,
                         precarg = pprecarg
                   WHERE cramo = pcramo
                     AND cmodali = pcmodali
                     AND ccolect = pccolect
                     AND ctipseg = pctipseg
                     AND sproduc = psproduc
                     AND cactivi = pcactivi
                     AND cforpag = pcforpag;

                  nerror := 0;
                  RETURN 0;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, vobjectname, 0,
                                 'ERROR A L''MODIFICAR FORPAGRECACTI',
                                 SQLERRM || ' ' || SQLCODE);
                     nerror := 110722;   /*Error al insertar en la tabla FORPAGRECACTI*/
                     RETURN 1;
               END;
         END;
      END IF;
   END f_set_recactividad;

   /*************************************************************************
        Función que se utiliza para comprobar si existen pólizas de una actividad definida en un producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM OUT NERROR     : Código de error
        RETURN NUMBER        : número de error (0: operación correcta sino 1)
   *************************************************************************/
   FUNCTION f_exist_actpol(psproduc IN NUMBER, pcactivi IN NUMBER, nerror OUT NUMBER)
      RETURN NUMBER IS
      xcount         NUMBER := 0;
   BEGIN
      SELECT COUNT(1)
        INTO xcount
        FROM seguros
       WHERE sproduc = psproduc
         AND cactivi = pcactivi;

      IF xcount > 0 THEN
         nerror := 9000763;   --Hi han pòlisses assignades a aquesta actividad
         RETURN 1;
      ELSE
         nerror := 9000762;   --No bi han pòlisses assignades a aquesta actividad
         RETURN 0;
      END IF;
   END f_exist_actpol;

     /*************************************************************************
          Función que inserta preguntas por producto y actividad.
          PARAM IN PCRAMO      : Código del Ramo del producto
          PARAM IN PCMODALI    : Código de la Modalidad del producto
          PARAM IN PCTIPSEG    : Código del tipo de Seguro del producto
          PARAM IN PCCOLECT    : Código del la Colectividad del producto
          PARAM IN PSPRODUC    : Código del Identificador del producto
          PARAM IN PCACTIVI    : Código de la Actividad
          PARAM IN PCPREGUN    : Código de pregunta
          PARAM IN PCPRETIP    : Código tipo de respuesta (manual,automática) valor fijo: 787
          PARAM IN PNPREORD    : Número de orden en el que se pregunta
          PARAM IN PTPREFOR    : Fórmula para plantear la pregunta
          PARAM IN PCPREOBL    : Obligatorio (Sí-1,No-0)
          PARAM IN PNPREIMP    : Orden de impresión
          PARAM IN PCRESDEF    : Respuesta por defecto
          PARAM IN PCOFERSN    : Código: Aparece en ofertas? (Sí-1,No-0)
          PARAM IN PTVALOR     : Fórmula para validar la respuesta
          PARAM OUT NERROR     : Código de error
          RETURN NUMBER        : número de error (0: operación correcta sino 1)
   *************************************************************************/
   FUNCTION f_set_pregactividad(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcpregun IN NUMBER,
      pcpretip IN NUMBER,
      pnpreord IN NUMBER,
      ptprefor IN VARCHAR2,
      pcpreobl IN NUMBER,
      pnpreimp IN NUMBER,
      pcresdef IN NUMBER,
      pcofersn IN NUMBER,
      ptvalfor IN VARCHAR2,
      nerror OUT NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MNTROP.F_set_pregactividad';
   BEGIN
      INSERT INTO pregunproactivi
                  (cramo, cmodali, ccolect, ctipseg, cactivi, cpregun, sproduc,
                   cpretip, npreord, tprefor, cpreobl, npreimp, cresdef, cofersn,
                   tvalfor)
           VALUES (pcramo, pcmodali, pccolect, pctipseg, pcactivi, pcpregun, psproduc,
                   pcpretip, pnpreord, ptprefor, pcpreobl, pnpreimp, pcresdef, pcofersn,
                   ptvalfor);

      nerror := 0;
      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         BEGIN
            UPDATE pregunproactivi
               SET cramo = pcramo,
                   cmodali = pcmodali,
                   ccolect = pccolect,
                   ctipseg = pctipseg,
                   cactivi = pcactivi,
                   cpregun = pcpregun,
                   sproduc = psproduc,
                   cpretip = pcpretip,
                   npreord = pnpreord,
                   tprefor = ptprefor,
                   cpreobl = pcpreobl,
                   npreimp = pnpreimp,
                   cresdef = pcresdef,
                   cofersn = pcofersn,
                   tvalfor = ptvalfor
             WHERE cramo = pcramo
               AND cmodali = pcmodali
               AND ccolect = pccolect
               AND ctipseg = pctipseg
               AND cactivi = pcactivi
               AND cpregun = pcpregun;

            nerror := 0;
            RETURN 0;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, vobjectname, 0, 'VALORS DUPLICATS',
                           SQLERRM || ' ' || SQLCODE);
               nerror := 151021;   /*Error a l'inserir a la taula PREGUNPROACTIVI*/
               RETURN 1;
         END;
   END f_set_pregactividad;

/*************************************************************************
        Función que se utiliza para borrar la actividad definida en un producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM OUT NERROR     : Código de error
        RETURN NUMBER        : Código de error (0: operación correcta sino 1)
   *************************************************************************/
   FUNCTION f_borrar_actividades(psproduc IN NUMBER, pcactivi IN NUMBER, nerror OUT NUMBER)
      RETURN NUMBER IS
      vcramo         productos.cramo%TYPE;
      vcmodali       productos.cmodali%TYPE;
      vctipseg       productos.ctipseg%TYPE;
      vccolect       productos.ccolect%TYPE;
      num_franq      NUMBER := 0;
      vcfranq        NUMBER := 0;
      num_bonus      NUMBER := 0;
      vobjectname    VARCHAR2(100) := 'PAC_MNTROP.F_borrar_actividades';

      --CURSOR BONUS POR PRODUCTO Y ACTIVIDAD
      CURSOR cur_bonus IS
         SELECT sbonus
           FROM codbonus
          WHERE sproduc = psproduc
            AND cactivi = pcactivi;

      --CURSOR ZONA POR PRODUCTO Y ACTIVIDAD
      CURSOR cur_zona IS
         SELECT szonif
           FROM codzonif
          WHERE sproduc = psproduc
            AND cactivi = pcactivi;
   BEGIN
      --BORRAR FRANQUICIAS DEFINIDAS
      BEGIN
         SELECT cramo, cmodali, ctipseg, ccolect
           INTO vcramo, vcmodali, vctipseg, vccolect
           FROM productos
          WHERE sproduc = psproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, vobjectname, 0, 'NO HI HA PRODUCTE',
                        SQLERRM || ' ' || SQLCODE);
            RETURN 1;
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobjectname, 1, 'ALTRES ERRORS DE PRODUCTE',
                        SQLERRM || ' ' || SQLCODE);
            RETURN 1;
      END;

      BEGIN
         SELECT COUNT(1)
           INTO num_franq
           FROM codifranquicias
          WHERE cramo = vcramo
            AND cmodali = vcmodali
            AND ctipseg = vctipseg
            AND ccolect = vccolect
            AND cactivi = pcactivi;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            num_franq := 0;
         WHEN OTHERS THEN
            num_franq := 0;
      END;

      IF num_franq = 1 THEN
         BEGIN
            SELECT cfranq
              INTO vcfranq
              FROM codifranquicias
             WHERE cramo = vcramo
               AND cmodali = vcmodali
               AND ctipseg = vctipseg
               AND ccolect = vccolect
               AND cactivi = pcactivi;
         EXCEPTION
            WHEN OTHERS THEN
               vcfranq := NULL;
         END;
      END IF;

      IF num_franq > 0 THEN
         DELETE FROM desfranquicias
               WHERE cactivi = pcactivi;

         DELETE FROM codifranquicias
               WHERE cactivi = pcactivi;
      END IF;

      --SÓLO SI HAY UNA FRANQUICIA POR PRODUCTO Y ACTIVIDAD
      IF num_franq = 1
         AND vcfranq IS NOT NULL THEN
         DELETE FROM detfranqgaran
               WHERE cfranq = vcfranq;

         DELETE FROM franqgaran
               WHERE cfranq = vcfranq;

         DELETE FROM franquiciasver
               WHERE cfranq = vcfranq;

         DELETE FROM grpfranquicias
               WHERE cfranq = vcfranq;

         DELETE FROM desgrpfranquicias
               WHERE cfranq = vcfranq;

         DELETE FROM grpfranquicias
               WHERE cfranq = vcfranq;
      END IF;

      --BORRAR BONUS
      FOR reg IN cur_bonus LOOP
         DELETE      desbonus
               WHERE sbonus = reg.sbonus;

         DELETE      hisbonus
               WHERE sbonus = reg.sbonus;

         DELETE      codbonus
               WHERE sbonus = reg.sbonus
                 AND sproduc = psproduc
                 AND cactivi = pcactivi;
      END LOOP;

      --BORRAR TABLAS DEPENDIENTES DE GARANTIAS
      DELETE FROM capitalmin
            WHERE sproduc = psproduc
              AND cactivi = pcactivi;

      DELETE FROM clausugar
            WHERE cramo = vcramo
              AND cmodali = vcmodali
              AND ctipseg = vctipseg
              AND ccolect = vccolect
              AND cactivi = pcactivi;

      DELETE FROM cum_cumgaran
            WHERE cramo = vcramo
              AND cmodali = vcmodali
              AND ctipseg = vctipseg
              AND ccolect = vccolect
              AND cactivi = pcactivi;

      DELETE FROM forpagrecgaran
            WHERE cramo = vcramo
              AND cmodali = vcmodali
              AND ctipseg = vctipseg
              AND ccolect = vccolect
              AND cactivi = pcactivi;

      DELETE FROM garanformula
            WHERE cramo = vcramo
              AND cmodali = vcmodali
              AND ctipseg = vctipseg
              AND ccolect = vccolect
              AND cactivi = pcactivi;

      DELETE FROM garanprotramit
            WHERE sproduc = psproduc
              AND cactivi = pcactivi;

      DELETE FROM garanzona
            WHERE sproduc = psproduc
              AND cactivi = pcactivi;

      DELETE FROM garanprocap
            WHERE cramo = vcramo
              AND cmodali = vcmodali
              AND ctipseg = vctipseg
              AND ccolect = vccolect
              AND cactivi = pcactivi;

      DELETE FROM garanprogas
            WHERE cramo = vcramo
              AND cmodali = vcmodali
              AND ctipseg = vctipseg
              AND ccolect = vccolect
              AND cactivi = pcactivi;

      DELETE FROM incompgaran
            WHERE cramo = vcramo
              AND cmodali = vcmodali
              AND ctipseg = vctipseg
              AND ccolect = vccolect
              AND cactivi = pcactivi;

      DELETE FROM intcomprogar
            WHERE cramo = vcramo
              AND cmodali = vcmodali
              AND ctipseg = vctipseg
              AND ccolect = vccolect
              AND cactivi = pcactivi;

      DELETE FROM intertecgar
            WHERE sproduc = psproduc
              AND cactivi = pcactivi;

      DELETE FROM intprogar
            WHERE cramo = vcramo
              AND cmodali = vcmodali
              AND ctipseg = vctipseg
              AND ccolect = vccolect
              AND cactivi = pcactivi;

      DELETE FROM par_perfiles_usuario
            WHERE cramo = vcramo
              AND cmodali = vcmodali
              AND ctipseg = vctipseg
              AND ccolect = vccolect
              AND cactivi = pcactivi;

      DELETE FROM par_reglas_aplicables
            WHERE cramo = vcramo
              AND cmodali = vcmodali
              AND ctipseg = vctipseg
              AND ccolect = vccolect
              AND cactivi = pcactivi;

      DELETE FROM pargaranpro
            WHERE cramo = vcramo
              AND cmodali = vcmodali
              AND ctipseg = vctipseg
              AND ccolect = vccolect
              AND sproduc = psproduc
              AND cactivi = pcactivi;

      DELETE FROM pregunprogaran
            WHERE sproduc = psproduc
              AND cactivi = pcactivi;

      DELETE FROM prodcaumotsin
            WHERE cramo = vcramo
              AND cmodali = vcmodali
              AND ctipseg = vctipseg
              AND ccolect = vccolect
              AND sproduc = psproduc
              AND cactivi = pcactivi;

      DELETE FROM ulprede
            WHERE cramo = vcramo
              AND cmodali = vcmodali
              AND ctipseg = vctipseg
              AND ccolect = vccolect
              AND cactivi = pcactivi;

      DELETE FROM vinculaciones_prod
            WHERE cramo = vcramo
              AND cmodali = vcmodali
              AND ctipseg = vctipseg
              AND ccolect = vccolect
              AND cactivi = pcactivi;

      DELETE FROM comisiongar
            WHERE cramo = vcramo
              AND cmodali = vcmodali
              AND ctipseg = vctipseg
              AND ccolect = vccolect
              AND cactivi = pcactivi;

      DELETE FROM comisioncamp
            WHERE cramo = vcramo
              AND cmodali = vcmodali
              AND ctipseg = vctipseg
              AND ccolect = vccolect
              AND cactivi = pcactivi;

      DELETE FROM detcampanya
            WHERE sproduc = psproduc
              AND cactivi = pcactivi;

      DELETE FROM imprec
            WHERE cramo = vcramo
              AND cmodali = vcmodali
              AND ctipseg = vctipseg
              AND ccolect = vccolect
              AND cactivi = pcactivi;

      DELETE FROM detcarencias
            WHERE cramo = vcramo
              AND cmodali = vcmodali
              AND ctipseg = vctipseg
              AND ccolect = vccolect
              AND sproduc = psproduc
              AND cactivi = pcactivi;

      DELETE FROM hisdetcarencias
            WHERE sproduc = psproduc
              AND cactivi = pcactivi;

      DELETE FROM contexcl
            WHERE cramo = vcramo
              AND cactivi = pcactivi;

      DELETE FROM garanpro_sbpri_prof
            WHERE cramo = vcramo
              AND cmodali = vcmodali
              AND ctipseg = vctipseg
              AND ccolect = vccolect
              AND cactivi = pcactivi;

      DELETE FROM garanpro_sbpri_depor
            WHERE cramo = vcramo
              AND cmodali = vcmodali
              AND ctipseg = vctipseg
              AND ccolect = vccolect
              AND cactivi = pcactivi;

      DELETE FROM garanpro
            WHERE cramo = vcramo
              AND cmodali = vcmodali
              AND ctipseg = vctipseg
              AND ccolect = vccolect
              AND sproduc = psproduc
              AND cactivi = pcactivi;

      --OTRAS TABLAS QUE DEPENDEN DE ACTIVIPROD
      FOR reg IN cur_zona LOOP
         DELETE FROM hiszonif
               WHERE szonif = reg.szonif;

         DELETE FROM actprozonif
               WHERE szonif = reg.szonif;

         DELETE FROM deszonif
               WHERE szonif = reg.szonif;

         DELETE FROM garanzona
               WHERE sproduc = psproduc
                 AND cactivi = pcactivi
                 AND szonif = reg.szonif;

         DELETE FROM codzonif
               WHERE szonif = reg.szonif
                 AND sproduc = psproduc
                 AND cactivi = pcactivi;
      END LOOP;

      DELETE FROM comisionacti
            WHERE cramo = vcramo
              AND cmodali = vcmodali
              AND ctipseg = vctipseg
              AND ccolect = vccolect
              AND cactivi = pcactivi;

      DELETE FROM pregunproactivi
            WHERE cramo = vcramo
              AND cmodali = vcmodali
              AND ctipseg = vctipseg
              AND ccolect = vccolect
              AND sproduc = psproduc
              AND cactivi = pcactivi;

      DELETE FROM forpagrecacti
            WHERE cramo = vcramo
              AND cmodali = vcmodali
              AND ctipseg = vctipseg
              AND ccolect = vccolect
              AND sproduc = psproduc
              AND cactivi = pcactivi;

      DELETE FROM paractividad
            WHERE sproduc = psproduc
              AND cactivi = pcactivi;

      DELETE FROM activiprod
            WHERE cramo = vcramo
              AND cmodali = vcmodali
              AND ctipseg = vctipseg
              AND ccolect = vccolect
              AND cactivi = pcactivi;

      nerror := 0;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         nerror := 108017;   --error al borrar en las tablas
         p_tab_error(f_sysdate, f_user, vobjectname, 0,
                     'NO S''HA POGUT ESBORRAR ALGUNA DE LES TAULES',
                     SQLERRM || ' ' || SQLCODE);
         RETURN 1;
   END f_borrar_actividades;

    /*************************************************************************
         Función que duplica actividad.
         PARAM IN PCRAMO      : Código del Ramo del producto
         PARAM IN PCMODALI    : Código de la Modalidad del producto
         PARAM IN PCTIPSEG    : Código del tipo de Seguro del producto
         PARAM IN PCCOLECT    : Código del la Colectividad del producto
         PARAM IN PSPRODUC    : Código del Identificador del producto
         PARAM IN PCACTIVI    : Código de la Actividad
         PARAM IN PCACTIVIC   : Código de la Actividad destino
         RETURN NUMBER        : Código de error (0: operación correcta sino 1)
   **********************************************************************/
   FUNCTION f_duplicar_actividades(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcactivic IN NUMBER)
      RETURN NUMBER IS
      nerror         NUMBER := 0;
   BEGIN
      /*Ini Bug ICV 30/04/2009 Bug 8510 - Se corrige el paso de parámetros a f_dup_Actividad*/
      nerror := pac_duplicar.f_dup_actividad(pcramo, pcmodali, pctipseg, pccolect, pcactivi,
                                             pcactivic, NULL);
      /*Fin Bug ICV 30/04/2009 Bug 8510*/
      RETURN nerror;
   END f_duplicar_actividades;

/*******FI BUG8510*********/

   /*************************************************************************
         Función para asignar cláusulas de beneficiario al producto
         PARAM IN PSPRODUC    : Código del Identificador del producto
         PARAM IN PSCLABEN    : Código de la clausula
         RETURN NUMBER        : Código de error (0: operación correcta sino 1)

         Bug 10557   29/06/2009  AMC
   **********************************************************************/
   FUNCTION f_set_benefpro(psproduc IN NUMBER, psclaben IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_MNTROP.f_set_benefpro';
      vparamname     VARCHAR2(400) := ' psproduc:' || psproduc || ' psclaben:' || psclaben;
      vnorden        NUMBER;
   BEGIN
      SELECT NVL(MAX(norden), 1)
        INTO vnorden
        FROM claubenpro
       WHERE sproduc = psproduc;

      INSERT INTO claubenpro
                  (sproduc, norden, sclaben)
           VALUES (psproduc, vnorden, psclaben);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname || vparamname, 0, SQLERRM, SQLCODE);
         RETURN 1;
   END f_set_benefpro;

   /*************************************************************************
         Función para asignar una cláusula de beneficiario por defecto al producto
         PARAM IN PSPRODUC    : Código del Identificador del producto
         PARAM IN PSCLABEN    : Código de la clausula
         RETURN NUMBER        : Código de error (0: operación correcta sino 1)

         Bug 10557   29/06/2009  AMC
   **********************************************************************/
   FUNCTION f_set_benefdefecto(psproduc IN NUMBER, psclaben IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_MNTROP.F_SET_BENEFDEFECTO';
      vparamname     VARCHAR2(400) := ' psproduc:' || psproduc || ' psclaben:' || psclaben;
   BEGIN
      UPDATE productos
         SET sclaben = psclaben
       WHERE sproduc = psproduc;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname || vparamname, 0, SQLERRM, SQLCODE);
         RETURN 1;
   END f_set_benefdefecto;

   /*************************************************************************
         Función que se utiliza para desasignar una cláusula del producto
         PARAM IN PSPRODUC    : Código del Identificador del producto
         PARAM IN PSCLABEN    : Código de la clausula
         PARAM OUT PNERROR    : Código del error
         RETURN NUMBER        : Código de error (0: operación correcta sino 1)

         Bug 10557   29/06/2009  AMC
   **********************************************************************/
   FUNCTION f_del_benefpro(psproduc IN NUMBER, psclaben IN NUMBER, pnerror OUT NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_MNTROP.F_DEL_BENEFPRO';
      vparamname     VARCHAR2(400) := ' psproduc:' || psproduc || ' psclaben:' || psclaben;
      vclaudef       NUMBER;
   BEGIN
      DELETE      claubenpro
            WHERE sproduc = psproduc
              AND sclaben = psclaben;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname || vparamname, 0, SQLERRM, SQLCODE);
         RETURN 1;
   END f_del_benefpro;

   /*************************************************************************
         Función que retorna las cláusulas de beneficirio no asignadas a un producto
         PARAM IN PSPRODUC    : Código del Identificador del producto
         PARAM IN PCIDIOMA    : Código del idioma
         RETURN sys_refcursor

         Bug 10557   29/06/2009  AMC
   **********************************************************************/
   FUNCTION f_get_benef_noasig(psproduc IN NUMBER, pcidioma IN NUMBER)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(100) := 'PAC_MNTPROD.F_GET_BENEF_NOASIG';
      vparam         VARCHAR2(400) := ' psproduc:' || psproduc || ' pcidioma:' || pcidioma;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
      cur            sys_refcursor;
      squery         VARCHAR2(400);
   BEGIN
      IF psproduc IS NULL
         OR pcidioma IS NULL THEN
         RAISE e_param_error;
      END IF;

      squery := 'SELECT C.SCLABEN, C.TCLABEN' || ' FROM CLAUSUBEN C' || ' WHERE CIDIOMA ='
                || pcidioma || ' AND NOT EXISTS' || ' (SELECT 1' || ' FROM CLAUBENPRO CP'
                || ' WHERE CP.SPRODUC =' || psproduc || ' AND CP.SCLABEN = C.SCLABEN)';

      OPEN cur FOR squery;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname || vparam, 0, SQLERRM, SQLCODE);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_benef_noasig;

   /*************************************************************************
         Función que asigna una garantia a un producto
         PARAM IN PSPRODUC    : Código del Identificador del producto
         PARAM IN PCGARANT    : Código de la garantia
         PARAM IN PCACTIVI    : Código de la actividad
         PARAM IN PNORDEN     : Numero de orden
         PARAM IN PCTIPGAR    : Código de tipo de garantia
         PARAM IN PCTIPCAR    : Código de tipo de capital
         RETURN NUMBER

         Bug 14284   26/04/2010  AMC
   **********************************************************************/
   FUNCTION f_set_garantiaprod(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      pnorden IN NUMBER,
      pctipgar IN NUMBER,
      pctipcap IN NUMBER)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
   BEGIN
      IF psproduc IS NULL
         OR pcgarant IS NULL
         OR pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := f_def_producto(psproduc, vcramo, vcmodali, vctipseg, vccolect);

      BEGIN
         INSERT INTO garanpro
                     (cmodali, ccolect, cramo, cgarant, ctipseg, cactivi, norden,
                      ctipgar, ctipcap, ctiptar, sproduc)
              VALUES (vcmodali, vccolect, vcramo, pcgarant, vctipseg, pcactivi, pnorden,
                      pctipgar, pctipcap, 0, psproduc);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE garanpro
               SET norden = pnorden,
                   ctipgar = pctipgar,
                   ctipcap = pctipcap
             WHERE cmodali = vcmodali
               AND ccolect = vccolect
               AND cramo = vcramo
               AND cgarant = pcgarant
               AND ctipseg = vctipseg
               AND cactivi = pcactivi;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_mntprod.f_set_garantiaprod', 1,
                     ' psproduc:' || psproduc || ' pcgarant:' || pcgarant || ' pcactivi:'
                     || pcactivi || ' pnorden:' || pnorden || ' pctipgar:' || pctipgar
                     || ' pctipcap:' || pctipcap,
                     SQLERRM);
         RETURN 9901155;
   END f_set_garantiaprod;

   /*************************************************************************
          Función que retorna los parametros de codipargar
          PARAM IN PCIDIOMA    : Código del idioma
          RETURN sys_refcursor

          Bug 14284   29/04/2010  AMC
    **********************************************************************/
   FUNCTION f_get_pargarantia(pcidioma IN NUMBER)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(100) := 'PAC_MNTPROD.f_get_pargarantia';
      vparam         VARCHAR2(400) := 'pcidioma:' || pcidioma;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
      cur            sys_refcursor;
      squery         VARCHAR2(400);
   BEGIN
      squery := 'select cpargar,tpargar FROM codipargar WHERE CIDIOMA =' || pcidioma;

      OPEN cur FOR squery;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname || vparam, 0, SQLERRM, SQLCODE);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_pargarantia;

   /*************************************************************************
         Función que retorna la lista de valores de un parametro
         PARAM IN PCPARGAR    : codigo del parametro
         PARAM IN PCIDIOMA    : Código del idioma
         RETURN sys_refcursor

         Bug 14284   29/04/2010  AMC
   **********************************************************************/
   FUNCTION f_get_valpargarantia(pcpargar IN VARCHAR2, pcidioma IN NUMBER)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(100) := 'PAC_MNTPROD.f_get_valpargarantia';
      vparam         VARCHAR2(400) := 'pcpargar:' || pcpargar || ' pcidioma:' || pcidioma;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
      cur            sys_refcursor;
      squery         VARCHAR2(400);
   BEGIN
      squery := 'select cvalpar,tvalpar FROM detpargar WHERE CPARGAR =''' || pcpargar
                || ''' and CIDIOMA =' || pcidioma;

      OPEN cur FOR squery;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname || vparam, 0, SQLERRM, SQLCODE);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_valpargarantia;

   /*************************************************************************
         Función que retorna el tipo de respuesta del parametro
         PARAM IN PCPARGAR    : codigo del parametro
         RETURN NUMBER

         Bug 14284   29/04/2010  AMC
   **********************************************************************/
   FUNCTION f_get_ctipoparam(pcpargar IN VARCHAR2)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_MNTPROD.f_get_ctipoparam';
      vparam         VARCHAR2(400) := 'pcpargar:' || pcpargar;
      vpasexec       NUMBER := 1;
      vctipo         NUMBER;
   BEGIN
      SELECT ctipo
        INTO vctipo
        FROM codparam
       WHERE cparam = pcpargar;

      RETURN vctipo;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname || vparam, 0, SQLERRM, SQLCODE);
         RETURN NULL;
   END f_get_ctipoparam;

   /*************************************************************************
         Función que inserta en garanprocap
         PARAM IN PCRAMO      : codigo de ramo
         PARAM IN PCMODALI    : codigo de modalidad
         PARAM IN PCTIPSEG    : codigo de tipo de seguro
         PARAM IN PCCOLECT    : codigo de colectivo
         PARAM IN PCGARANT    : codigo de la garantia
         PARAM IN PCACTIVI    : codigo de la actividad
         PARAM IN PNORDEN     : numero de orden
         PARAM IN PICAPITAL   : importe del capital
         PARAM IN PCDEFECTO   : por defecto 0-No/1-Si
         RETURN NUMBER

         Bug 14284   29/04/2010  AMC
   **********************************************************************/
   FUNCTION f_set_capital(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      pnorden IN NUMBER,
      picapital IN NUMBER,
      pcdefecto IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_MNTPROD.f_get_ctipoparam';
      vparam         VARCHAR2(400)
         := 'pcramo:' || pcramo || ' pcmodali:' || pcmodali || ' pctipseg:' || pctipseg
            || ' pccolect:' || pccolect || ' pcgarant:' || pcgarant || ' pcactivi:'
            || pcactivi || ' pnorden:' || pnorden || ' picapital:' || picapital
            || ' pcdefecto:' || pcdefecto;
      vpasexec       NUMBER := 1;
      vctipo         NUMBER;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      verror         NUMBER;
   BEGIN
      INSERT INTO garanprocap
                  (cramo, cmodali, ctipseg, ccolect, cgarant, cactivi, norden,
                   icapital, cdefecto)
           VALUES (pcramo, pcmodali, pctipseg, pccolect, pcgarant, pcactivi, pnorden,
                   picapital, pcdefecto);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname || vparam, 0, SQLERRM, SQLCODE);
         RETURN 1;
   END f_set_capital;

      /*************************************************************************
         Función que borrar los capitales de un garantia en garanprocap
         PARAM IN PCRAMO      : codigo de ramo
         PARAM IN PCMODALI    : codigo de modalidad
         PARAM IN PCTIPSEG    : codigo de tipo de seguro
         PARAM IN PCCOLECT    : codigo de colectivo
         PARAM IN PCGARANT    : codigo de la garantia
         PARAM IN PCACTIVI    : codigo de la actividad
         RETURN NUMBER

         Bug 14284   29/04/2010  AMC
   **********************************************************************/
   FUNCTION f_del_capitales(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_MNTPROD.f_get_ctipoparam';
      vparam         VARCHAR2(400)
         := 'pcramo:' || pcramo || ' pcmodali:' || pcmodali || ' pctipseg:' || pctipseg
            || ' pccolect:' || pccolect || ' pcgarant:' || pcgarant || ' pcactivi:'
            || pcactivi;
      vpasexec       NUMBER := 1;
      vctipo         NUMBER;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      verror         NUMBER;
   BEGIN
      DELETE      garanprocap
            WHERE cramo = pcramo
              AND cmodali = pcmodali
              AND ctipseg = pctipseg
              AND ccolect = pccolect
              AND cgarant = pcgarant
              AND cactivi = pcactivi;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname || vparam, 0, SQLERRM, SQLCODE);
         RETURN 1;
   END f_del_capitales;

   /*************************************************************************
         Función que retorna la lista de capitales de una garantia
         param in psproduc  : codigo del producto
         param in pcgarant  : codigo de la garantia
         param in pcactivi  : codigo de la actividad
         RETURN sys_refcursor

         Bug 14284   29/04/2010  AMC
   **********************************************************************/
   FUNCTION f_get_listcapitales(psproduc IN NUMBER, pcgarant IN NUMBER, pcactivi IN NUMBER)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(100) := 'PAC_MNTPROD.f_get_listcapitales';
      vparam         VARCHAR2(400)
            := 'psproduc:' || psproduc || ' pcgarant:' || pcgarant || ' pcactivi:' || pcactivi;
      vpasexec       NUMBER := 1;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      verror         NUMBER;
      cur            sys_refcursor;
      squery         VARCHAR2(1000);
   BEGIN
      verror := f_def_producto(psproduc, vcramo, vcmodali, vctipseg, vccolect);
      squery := 'SELECT norden, icapital, cdefecto FROM garanprocap WHERE cramo=' || vcramo
                || ' AND cmodali=' || vcmodali || ' AND ctipseg=' || vctipseg
                || ' AND ccolect=' || vccolect || ' AND cgarant=' || pcgarant
                || ' AND cactivi=' || pcactivi || ' UNION ALL '
                || 'SELECT norden, icapital, cdefecto FROM garanprocap WHERE cramo=' || vcramo
                || ' AND cmodali=' || vcmodali || ' AND ctipseg=' || vctipseg
                || ' AND ccolect=' || vccolect || ' AND cgarant=' || pcgarant
                || ' AND cactivi=0 AND NOT EXISTS (SELECT 1 FROM garanprocap g1'
                || ' WHERE g1.cramo=' || vcramo || ' AND g1.cmodali=' || vcmodali
                || ' AND g1.ctipseg=' || vctipseg || ' AND g1.ccolect=' || vccolect
                || ' AND g1.cgarant=' || pcgarant || ' AND g1.cactivi=' || pcactivi
                || ')  ORDER BY 1';

      OPEN cur FOR squery;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname || vparam, 0, SQLERRM, SQLCODE);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_listcapitales;

   /*************************************************************************
           Función que retorna els documentos d'un producte
           param in psproduc  : codigo del producto

           RETURN sys_refcursor

           Bug 14284   29/04/2010  AMC
     **********************************************************************/
   FUNCTION f_get_documentos(psproduc IN NUMBER, pcidioma IN NUMBER)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(100) := 'PAC_MNTPROD.f_get_documentos';
      vparam         VARCHAR2(400) := 'psproduc:' || psproduc;
      vpasexec       NUMBER := 1;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      verror         NUMBER;
      cur            sys_refcursor;
      squery         VARCHAR2(1000);
   BEGIN
      squery :=
         'select sproduc,ff_Desvalorfijo (317,' || pcidioma
         || ',ctipo) ttipo, d.tdescrip, ppc.cduplica,d.cinforme
                            from prod_plant_cab ppc, detplantillas d
                            where  sproduc='
         || psproduc
         || '
                            and ppc.ccodplan = d.ccodplan
                            and d.cidioma = '
         || pcidioma || ' order by d.tdescrip';

      OPEN cur FOR squery;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname || vparam, 0, SQLERRM, SQLCODE);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_documentos;

   /*************************************************************************
         Función que actualiza los datos generales de la garantia
         param in psproduc  : codigo del producto
         param in pcgarant  : codigo de la garantia
         param in pcactivi  : codigo de la actividad
         param in pnorden   : numero de orden
         param in pctipgar  : codigo tipo de garantia
         param in pctipcap  : codigo tipo de capital
         param in pcgardep  : codigo garantia dependiente
         param in pcpardep  : codigo parametro dependiente
         param in pcvalpar  : valor parametro dependiente
         param in pctarjet
         param in pcbasica
         param in picapmax  : importe capital maximo
         param in pccapmax  : codigo capital maximo
         param in pcformul  : codigo de formula
         param in pcclacap  :
         param in picaprev  : capital de revision
         param in ppcapdep  :
         param in piprimin  : prima minima
         param in piprimax  : capital maximo
         param in picapmin  : capital minimo
         RETURN number

         Bug 14284   07/05/2010  AMC
   **********************************************************************/
   FUNCTION f_set_datosgen(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      pnorden IN NUMBER,
      pctipgar IN NUMBER,
      pctipcap IN NUMBER,
      pcgardep IN NUMBER,
      pcpardep IN VARCHAR2,
      pcvalpar IN NUMBER,
      pctarjet IN NUMBER,
      pcbasica IN NUMBER,
      picapmax IN NUMBER,
      pccapmax IN NUMBER,
      pcformul IN NUMBER,
      pcclacap IN NUMBER,
      picaprev IN NUMBER,
      ppcapdep IN NUMBER,
      piprimin IN NUMBER,
      piprimax IN NUMBER,
      pccapmin IN NUMBER,
      picapmin IN NUMBER,
      pcclamin IN NUMBER,
      pcmoncap IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_MNTPROD.f_set_datosgen';
      vparam         VARCHAR2(1000)
         := ' psproduc:' || psproduc || ' pcgarant:' || pcgarant || ' pcactivi:' || pcactivi
            || ' pnorden:' || pnorden || ' pctipgar:' || pctipgar || ' pctipcap:' || pctipcap
            || ' pcgardep:' || pcgardep || ' pcpardep:' || pcpardep || ' pcvalpar:'
            || pcvalpar || ' pctarjet:' || pctarjet || ' pcbasica:' || pcbasica
            || ' picapmax:' || picapmax || ' pccapmax:' || pccapmax || ' pcformul:'
            || pcformul || ' pcclacap:' || pcclacap || ' picaprev:' || picaprev
            || ' ppcapdep:' || ppcapdep || ' piprimin:' || piprimin || ' piprimax:'
            || piprimax || ' pccapmin:' || pccapmin || ' picapmin:' || picapmin
            || ' pcclamin:' || pcclamin || ' pcmoncap:' || pcmoncap;
      vpasexec       NUMBER := 1;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      verror         NUMBER;
   BEGIN
      verror := f_def_producto(psproduc, vcramo, vcmodali, vctipseg, vccolect);

      IF verror <> 0 THEN
         RETURN 102705;
      END IF;

      UPDATE garanpro
         SET norden = pnorden,
             ctipgar = pctipgar,
             ctipcap = pctipcap,
             cgardep = pcgardep,
             cpardep = pcpardep,
             cvalpar = pcvalpar,
             ctarjet = pctarjet,
             cbasica = pcbasica,
             icapmax = picapmax,
             ccapmax = pccapmax,
             cformul = pcformul,
             cclacap = pcclacap,
             icaprev = picaprev,
             pcapdep = ppcapdep,
             iprimin = piprimin,
             iprimax = piprimax,
             ccapmin = pccapmin,
             icapmin = picapmin,
             cclamin = pcclamin,
             cmoncap = pcmoncap
       WHERE cmodali = vcmodali
         AND ccolect = vccolect
         AND cramo = vcramo
         AND ctipseg = vctipseg
         AND cgarant = pcgarant
         AND cactivi = pcactivi;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname || vparam, 0, SQLERRM, SQLCODE);
         RETURN 140999;
   END f_set_datosgen;

   /*************************************************************************
         Función que borrar una garantia asignada a un producto
         param in psproduc  : código del producto
         param in pcactivi  : código de la actividad
         param in pcgarant  : código de la garantia
         RETURN number

         Bug 14723 - 25/05/2010 - AMC
   **********************************************************************/
   FUNCTION f_del_garantia(psproduc IN NUMBER, pcactivi IN NUMBER, pcgarant IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_MNTPROD.f_del_garantia';
      vparam         VARCHAR2(400)
            := 'psproduc:' || psproduc || ' pcactivi:' || pcactivi || ' pcgarant:' || pcgarant;
      vpasexec       NUMBER := 1;
      vcount         NUMBER;
      verror         NUMBER;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
   BEGIN
      -- Comprobamos de que no se haiga contratado ningun seguro con la garantia a borrar
      SELECT COUNT(s.sseguro)
        INTO vcount
        FROM garanseg g, seguros s
       WHERE s.sproduc = psproduc
         AND g.sseguro = s.sseguro
         AND g.cgarant = pcgarant;

      IF vcount > 0 THEN
         RETURN 9901211;
      END IF;

      verror := f_def_producto(psproduc, vcramo, vcmodali, vctipseg, vccolect);

      IF verror <> 0 THEN
         RETURN 102705;
      END IF;

      -- Si la actividad es la 0 comprobamos que la garantia no este asignada a otra actividad
      IF pcactivi = 0 THEN
         SELECT COUNT(1)
           INTO vcount
           FROM garanpro
          WHERE cramo = vcramo
            AND cmodali = vcmodali
            AND ctipseg = vctipseg
            AND ccolect = vccolect
            AND cgarant = pcgarant
            AND cactivi <> pcactivi;

         IF vcount > 0 THEN
            RETURN 9901211;
         END IF;
      END IF;

      DELETE FROM pargaranpro
            WHERE sproduc = psproduc
              AND cactivi = pcactivi
              AND cgarant = pcgarant;

      DELETE      garanpro
            WHERE cramo = vcramo
              AND cmodali = vcmodali
              AND ctipseg = vctipseg
              AND ccolect = vccolect
              AND cgarant = pcgarant
              AND cactivi = pcactivi;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname || vparam, 0, SQLERRM, SQLCODE);
         RETURN 9901941;
   END f_del_garantia;

   /*************************************************************************
         Función que actualiza los datos generales de la garantia
         param in psproduc  : codigo del producto
         param in pcgarant  : codigo de la garantia
         param in pcactivi  : codigo de la actividad
         param in pciedmic  : Ind. si se valida la 0-edad actuarial 1-edad real. Edad Min. Ctnr.
         param in pnedamic  : Edad mínima de contratación
         param in pciedmac  : Ind. si se valida la 0-edad actuarial 1-edad real. Edad Max. Ctnr.
         param in pnedamac, : Edad máxima de contratación
         param in pciedmar  : Ind. si se valida la 0-edad actuarial 1-edad real. Edad Max. Renov.
         param in pnedamar  : Edad máxima de renovación
         param in pciemi2c  : Ind. si se valida la 0-edad actuarial 1-edad real. Cuando se informa Edad Min. Ctnr. 2ºAsegurado
         param in pnedmi2c, : Edad Min. Ctnr. 2ºAsegurado
         param in pciema2c, : Ind. si se valida la 0-edad actuarial 1-edad real. Cuando se informa Edad Max. Ctnr. 2ºAsegurado
         param in pnedma2c  : Edad Max. Ctnr. 2ºAsegurado
         param in pciema2r  : Ind. si se valida la 0-edad actuarial 1-edad real. Cuando se informa Edad Max. Renov. 2ºAsegurado
         param in pnedma2r  : Edad Max. Renov. 2ºAsegurado
         param in pcreaseg
         param in pcrevali  : Tipo de revalorización
         param in pctiptar  : Tipo de tarifa (lista de valores)
         param in pcmodrev  : Se puede modificar la revalorización
         param in pcrecarg  : Se puede añadir un recargo
         param in pcdtocom  : Admite descuento comercial
         param in pctecnic
         param in pcofersn
         param in pcextrap  : Se puede modificar la extraprima
         param in pcderreg
         param in pprevali  : Porcentaje de revalorización
         param in pirevali  : Importe de revalorización
         param in pcrecfra
         param in pctarman
         param in pciedmrv  : Ind. si se valida la 0-edad actuarial 1-edad real. Edad Max. Revalorización
         param in pnedamrv  : Edad máxima de renovación
         RETURN number

         Bug 14748   04/06/2010  AMC
   **********************************************************************/
   FUNCTION f_set_datosges(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      pciedmic IN NUMBER,
      pnedamic IN NUMBER,
      pciedmac IN NUMBER,
      pnedamac IN NUMBER,
      pciedmar IN NUMBER,
      pnedamar IN NUMBER,
      pciemi2c IN NUMBER,
      pnedmi2c IN NUMBER,
      pciema2c IN NUMBER,
      pnedma2c IN NUMBER,
      pciema2r IN NUMBER,
      pnedma2r IN NUMBER,
      pcreaseg IN NUMBER,
      pcrevali IN NUMBER,
      pctiptar IN NUMBER,
      pcmodrev IN NUMBER,
      pcrecarg IN NUMBER,
      pcdtocom IN NUMBER,
      pctecnic IN NUMBER,
      pcofersn IN NUMBER,
      pcextrap IN NUMBER,
      pcderreg IN NUMBER,
      pprevali IN NUMBER,
      pirevali IN NUMBER,
      pcrecfra IN NUMBER,
      pctarman IN NUMBER,
      pnedamrv IN NUMBER,
      pciedmrv IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_MNTPROD.f_set_datosges';
      vparam         VARCHAR2(1000)
         := ' psproduc:' || psproduc || ' pcgarant:' || pcgarant || ' pcactivi:' || pcactivi
            || ' ciedmic:' || pciedmic || ' nedamic:' || pnedamic || ' ciedmac:' || pciedmac
            || ' nedamac:' || pnedamac || ' ciedmar:' || pciedmar || ' nedamar:' || pnedamar
            || ' ciemi2c:' || pciemi2c || ' nedmi2c:' || pnedmi2c || ' ciema2c:' || pciema2c
            || ' nedma2c:' || pnedma2c || ' ciema2r:' || pciema2r || ' nedma2r:' || pnedma2r
            || ' creaseg:' || pcreaseg || ' crevali:' || pcrevali || ' ctiptar:' || pctiptar
            || ' cmodrev:' || pcmodrev || ' crecarg:' || pcrecarg || ' cdtocom:' || pcdtocom
            || ' ctecnic:' || pctecnic || ' cofersn:' || pcofersn || ' cextrap:' || pcextrap
            || ' cderreg:' || pcderreg || ' prevali:' || pprevali || ' irevali:' || pirevali
            || ' crecfra:' || pcrecfra || ' pctarman:' || pctarman || ' pnedamrv:' || pnedamrv
            || ' pciedmrv:' || pciedmrv;
      vpasexec       NUMBER := 1;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      verror         NUMBER;
   BEGIN
      verror := f_def_producto(psproduc, vcramo, vcmodali, vctipseg, vccolect);

      IF verror <> 0 THEN
         RETURN 102705;
      END IF;

      UPDATE garanpro
         SET ciedmic = pciedmic,
             nedamic = pnedamic,
             ciedmac = pciedmac,
             nedamac = pnedamac,
             ciedmar = pciedmar,
             nedamar = pnedamar,
             ciemi2c = pciemi2c,
             nedmi2c = pnedmi2c,
             ciema2c = pciema2c,
             nedma2c = pnedma2c,
             ciema2r = pciema2r,
             nedma2r = pnedma2r,
             creaseg = pcreaseg,
             crevali = pcrevali,
             ctiptar = pctiptar,
             cmodrev = pcmodrev,
             crecarg = pcrecarg,
             cdtocom = pcdtocom,
             ctecnic = pctecnic,
             cofersn = pcofersn,
             cextrap = pcextrap,
             cderreg = pcderreg,
             prevali = pprevali,
             irevali = pirevali,
             crecfra = pcrecfra,
             ctarman = pctarman,
             nedamrv = pnedamrv,
             ciedmrv = pciedmrv
       WHERE cmodali = vcmodali
         AND ccolect = vccolect
         AND cramo = vcramo
         AND ctipseg = vctipseg
         AND cgarant = pcgarant
         AND cactivi = pcactivi;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname || vparam, 0, SQLERRM, SQLCODE);
         RETURN 140999;
   END f_set_datosges;

   /*************************************************************************
         Función que inserta en incompgaran
         PARAM IN PSPRODUC     : codigo del producto
         PARAM IN PCGARANT    : codigo de la garantia
         PARAM IN PCGARANT    : codigo de la garantia incompatible
         PARAM IN PCACTIVI    : codigo de la actividad

         RETURN NUMBER

         Bug 15023   16/06/2010  AMC
   **********************************************************************/
   FUNCTION f_set_incompagar(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcgarinc IN NUMBER,
      pcactivi IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_MNTPROD.f_set_incompagar';
      vparam         VARCHAR2(400)
         := 'psproduc:' || psproduc || ' pcgarant:' || pcgarant || ' pcactivi:' || pcactivi
            || ' pcgarinc:' || pcgarinc;
      vpasexec       NUMBER := 1;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      verror         NUMBER;
   BEGIN
      verror := f_def_producto(psproduc, vcramo, vcmodali, vctipseg, vccolect);

      IF verror <> 0 THEN
         RETURN 102705;
      END IF;

      INSERT INTO incompgaran
                  (cramo, cmodali, ctipseg, ccolect, cgarant, cgarinc, cactivi)
           VALUES (vcramo, vcmodali, vctipseg, vccolect, pcgarant, pcgarinc, pcactivi);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname || vparam, 0, SQLERRM, SQLCODE);
         RETURN 140999;
   END f_set_incompagar;

   /*************************************************************************
         Función que borra de incompgaran
         PARAM IN PSPRODUC     : codigo del producto
         PARAM IN PCGARANT    : codigo de la garantia
         PARAM IN PCGARANT    : codigo de la garantia incompatible
         PARAM IN PCACTIVI    : codigo de la actividad

         RETURN NUMBER

         Bug 15023   16/06/2010  AMC
   **********************************************************************/
   FUNCTION f_del_incompagar(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcgarinc IN NUMBER,
      pcactivi IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_MNTPROD.f_del_incompagar';
      vparam         VARCHAR2(400)
         := 'psproduc:' || psproduc || ' pcgarant:' || pcgarant || ' pcactivi:' || pcactivi
            || ' pcgarinc:' || pcgarinc;
      vpasexec       NUMBER := 1;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      verror         NUMBER;
   BEGIN
      verror := f_def_producto(psproduc, vcramo, vcmodali, vctipseg, vccolect);

      IF verror <> 0 THEN
         RETURN 102705;
      END IF;

      DELETE FROM incompgaran
            WHERE cramo = vcramo
              AND cmodali = vcmodali
              AND ctipseg = vctipseg
              AND ccolect = vccolect
              AND cgarant = pcgarant
              AND cgarinc = pcgarinc
              AND cactivi = pcactivi;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname || vparam, 0, SQLERRM, SQLCODE);
         RETURN 140999;
   END f_del_incompagar;

   /*************************************************************************
         Función que actualiza los datos tecnicos de la garantia
         param in psproduc  : codigo del producto
         param in pcgarant  : codigo de la garantia
         param in pcactivi  : codigo de la actividad
         param in pcramdgs  : código del ramo de la dgs
         param in pctabla   : código de la tabla de mortalidad
         param in precseg   : % recargo de seguridad
         param in nparben   : participación en beneficios

         RETURN number

         Bug 15148 - 21/06/2010 - AMC
   **********************************************************************/
   FUNCTION f_set_datostec(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      pcramdgs IN NUMBER,
      pctabla IN NUMBER,
      pprecseg IN NUMBER,
      pnparben IN NUMBER,
      pcprovis IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_MNTPROD.f_set_datostec';
      vparam         VARCHAR2(1000)
         := ' psproduc:' || psproduc || ' pcgarant:' || pcgarant || ' pcactivi:' || pcactivi
            || ' cramdgs:' || pcramdgs || ' ctabla:' || pctabla || ' precseg:' || pprecseg
            || ' nparben:' || pnparben || ' cprovis:' || pcprovis;
      vpasexec       NUMBER := 1;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      verror         NUMBER;
   BEGIN
      verror := f_def_producto(psproduc, vcramo, vcmodali, vctipseg, vccolect);

      IF verror <> 0 THEN
         RETURN 102705;
      END IF;

      UPDATE garanpro
         SET cramdgs = pcramdgs,
             ctabla = pctabla,
             precseg = pprecseg,
             nparben = pnparben,
             cprovis = pcprovis   -- Bug 32620 - 25/09/2014 - JTT
       WHERE cmodali = vcmodali
         AND ccolect = vccolect
         AND cramo = vcramo
         AND ctipseg = vctipseg
         AND cgarant = pcgarant
         AND cactivi = pcactivi;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname || vparam, 0, SQLERRM, SQLCODE);
         RETURN 140999;
   END f_set_datostec;

   /*************************************************************************
       Borra la formula de una garantia
       param in Psproduc      : código del producto
       param in Pcactivi    : código de la actividad
       param in Pcgarant    : código de la garantía
       param in Pccampo    : código del campo
       param in Pclave    : clave fórmula
       return               : 0 si ha ido bien
                             numero error si ha ido mal

       Bug 15149 - 29/06/2010 - AMC
   *************************************************************************/
   FUNCTION f_del_prodgarformulas(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pccampo IN VARCHAR2,
      pclave IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := 'psproduc=' || psproduc || ' pcactivi=' || pcactivi || ' pcgarant=' || pcgarant
            || ' pccampo=' || pccampo || ' pclave=' || pclave;
      vobject        VARCHAR2(200) := 'PAC_MNTPROD.f_del_prodgarformulas';
      xcramo         NUMBER;
      xcmodali       NUMBER;
      xctipseg       NUMBER;
      xccolect       NUMBER;
   BEGIN
      IF psproduc IS NULL
         OR pcactivi IS NULL
         OR pcgarant IS NULL
         OR pccampo IS NULL
         OR pclave IS NULL THEN
         RETURN 110087;
      END IF;

      vpasexec := 3;

      SELECT cramo, cmodali, ctipseg, ccolect
        INTO xcramo, xcmodali, xctipseg, xccolect
        FROM productos
       WHERE sproduc = psproduc;

      DELETE      garanformula
            WHERE cramo = xcramo
              AND cmodali = xcmodali
              AND ctipseg = xctipseg
              AND ccolect = xccolect
              AND cgarant = pcgarant
              AND ccampo = pccampo
              AND cactivi = pcactivi
              AND clave = pclave;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 110087;
   END f_del_prodgarformulas;

   /*************************************************************************
           Inserta un nuevo producto en la tabla PRODUCTOS
           param in psproduc_new  : código de produco creado
           param in psproduc_copy  : código de produco a copiar configuraciones
           return vnumerr  : Error
     *************************************************************************/
   FUNCTION f_duplica_cfg(
      psproduc_new IN NUMBER,
      psproduc_copy IN NUMBER,
      pparproductos IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      BEGIN
         INSERT INTO cfg_acceso_producto
                     (cempres, caccprod, sproduc, cemitir, cimprimir, cestudios, ccartera,
                      crecibos, caccesible)
            (SELECT cempres, caccprod, psproduc_new, cemitir, cimprimir, cestudios, ccartera,
                    crecibos, caccesible
               FROM cfg_acceso_producto
              WHERE sproduc = psproduc_copy);
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      BEGIN
         INSERT INTO cfg_accion
                     (cempres, ccfgacc, caccion, sproduc, crealiza)
            (SELECT cempres, ccfgacc, caccion, psproduc_new, crealiza
               FROM cfg_accion
              WHERE sproduc = psproduc_copy);
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      BEGIN
         INSERT INTO cfg_accion_recibo
                     (cempres, cestrec, caccion, ccfgacc, sproduc, cform, tform)
            (SELECT cempres, cestrec, caccion, ccfgacc, psproduc_new, cform, tform
               FROM cfg_accion_recibo
              WHERE sproduc = psproduc_copy);
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      BEGIN
         INSERT INTO cfg_avisos
                     (cempres, cform, cmodo, ccfgavis, cramo, sproduc, cidrel)
            (SELECT cempres, cform, cmodo, ccfgavis, cramo, psproduc_new, cidrel
               FROM cfg_avisos
              WHERE sproduc = psproduc_copy);
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      BEGIN
         INSERT INTO cfg_form
                     (cempres, cform, cmodo, ccfgform, sproduc, cidcfg)
            (SELECT cempres, cform, cmodo, ccfgform, psproduc_new, cidcfg
               FROM cfg_form
              WHERE sproduc = psproduc_copy);
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      BEGIN
         INSERT INTO cfg_lanzar_informes
                     (cempres, cform, cmap, tevento, sproduc, slitera, lparams, genera_report)
            (SELECT cempres, cform, cmap, tevento, psproduc_new, slitera, lparams,
                    genera_report
               FROM cfg_lanzar_informes
              WHERE sproduc = psproduc_copy);
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      BEGIN
         INSERT INTO cfg_notificacion
                     (cempres, cmodo, tevento, sproduc, scorreo)
            (SELECT cempres, cmodo, tevento, psproduc_new, scorreo
               FROM cfg_notificacion
              WHERE sproduc = psproduc_copy);
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      BEGIN
         INSERT INTO cfg_proceso_bpm
                     (cempres, sproduc, cperfil, cmodo, cproceso, cevento, cidcond, cidparam,
                      cusuario, cpassword, cactivo)
            (SELECT cempres, psproduc_new, cperfil, cmodo, cproceso, cevento, cidcond,
                    cidparam, cusuario, cpassword, cactivo
               FROM cfg_proceso_bpm
              WHERE sproduc = psproduc_copy);
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      BEGIN
         INSERT INTO cfg_tiposbajas
                     (cempres, sproduc, ctipbaja, ccfgacc)
            (SELECT cempres, psproduc_new, ctipbaja, ccfgacc
               FROM cfg_tiposbajas
              WHERE sproduc = psproduc_copy);
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      BEGIN
         INSERT INTO cfg_wizard
                     (cempres, cmodo, ccfgwiz, sproduc, cidcfg)
            (SELECT cempres, cmodo, ccfgwiz, psproduc_new, cidcfg
               FROM cfg_wizard
              WHERE sproduc = psproduc_copy);
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF pparproductos IS NOT NULL
         AND pparproductos = 1 THEN
         BEGIN
            DELETE      parproductos
                  WHERE sproduc = psproduc_new;

            INSERT INTO parproductos
                        (sproduc, cparpro, cvalpar, nagrupa, tvalpar, fvalpar)
               (SELECT psproduc_new, cparpro, cvalpar, nagrupa, tvalpar, fvalpar
                  FROM parproductos
                 WHERE sproduc = psproduc_copy);
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_MNTPRROD.duplicar 1', NULL,
                           'Error al insertar en parproductos', SQLERRM);
         END;
      END IF;

      BEGIN
         INSERT INTO pds_supl_config
                     (cconfig, cmotmov, sproduc, cmodo, ctipfec, tfecrec)
            (SELECT REPLACE(cconfig, psproduc_copy, psproduc_new), cmotmov, psproduc_new,
                    cmodo, ctipfec, tfecrec
               FROM pds_supl_config
              WHERE sproduc = psproduc_copy);

         INSERT INTO pds_supl_cod_config
                     (cconsupl, cconfig)
            (SELECT cconsupl, REPLACE(cconfig, psproduc_copy, psproduc_new)
               FROM pds_supl_cod_config
              WHERE cconfig LIKE '%' || psproduc_copy || '_s%');

         INSERT INTO pds_supl_validacio
                     (cconfig, nselect, tselect)
            (SELECT REPLACE(cconfig, psproduc_copy, psproduc_new), nselect, tselect
               FROM pds_supl_validacio
              WHERE cconfig LIKE '%' || psproduc_copy || '_s%');

         INSERT INTO pds_supl_form
                     (cconfig, tform)
            (SELECT REPLACE(cconfig, psproduc_copy, psproduc_new), tform
               FROM pds_supl_form
              WHERE cconfig LIKE '%' || psproduc_copy || '_s%');
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_MNTPRROD.duplicar 1', NULL,
                        'Error al insertar en pds_s', SQLERRM);
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MNTPRROD.f_duplica_cfg', NULL, 'f_duplica_cfg',
                     SQLERRM);
         RETURN(SQLERRM);
   END f_duplica_cfg;

   /*************************************************************************
         Inserta un nuevo producto en la tabla PRODUCTOS
         param in pcramo    : codigo del ramo
         param in pcmodali  : codigo de la modalidad
         param in pctipseg  : codigo del tipo de seguro
         param in pccolect  : codigo de colectividad
         param in pcagrpro  : codigo agrupacion de producto
         param in pcidioma  : codigo de idioma.
         param in pttitulo  : titulo del producto
         param in ptrotulo  : abreviacion del titulo
         param in pcsubpro  : codigo de subtipo de producto
         param in pctipreb  : recibo por.
         param in pctipges  : gestion del seguro
         param in pctippag  : cobro
         param in pcduraci  : codigo de la duración
         param in pctarman  : tarificacion puede ser manual
         param in pctipefe  : tipo de efecto
         param out psproduct_out  : codigo del producto insertado

         Bug 15513 - 23/07/2010 - PFA
   *************************************************************************/
   FUNCTION f_alta_producto(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcagrpro IN NUMBER,
      pcidioma IN NUMBER,
      pttitulo IN VARCHAR2,
      ptrotulo IN VARCHAR2,
      pcsubpro IN NUMBER,
      pctipreb IN NUMBER,
      pctipges IN NUMBER,
      pctippag IN NUMBER,
      pcduraci IN NUMBER,
      pctarman IN NUMBER,
      pctipefe IN NUMBER,
      psproduc_copy IN NUMBER,
      pparproductos IN NUMBER,
      psproduc_out IN OUT NUMBER)
      RETURN NUMBER IS
      vsproduc       NUMBER := psproduc_out;
      vsproduc_copy  NUMBER;
      vnumerr        NUMBER;

      CURSOR cur_idiomes IS
         SELECT cidioma
           FROM idiomas
          WHERE cvisible = 1;
   BEGIN
      IF psproduc_out IS NULL THEN
         SELECT (MAX(sproduc)) + 1
           INTO vsproduc
           FROM productos;
      END IF;

      INSERT INTO productos
                  (ctipseg, ccolect, cramo, cmodali, cagrpro, csubpro, cactivo, ctipreb,
                   ctipges, creccob, ctippag, cpagdef, cduraci, ctempor, ctarman, ctipefe,
                   cgarsin, cvalman, ctiprie, cvalfin, cprotec, crecfra, cimppri, cimptax,
                   cimpcon, sproduc, cdivisa)
           VALUES (pctipseg, pccolect, pcramo, pcmodali, pcagrpro, pcsubpro, 0, pctipreb,
                   pctipges, 1, pctippag, 12, pcduraci, 0, pctarman, pctipefe,
                   0, 0, 1, 1, 1, 0, 1, 1,
                   1, vsproduc, 3);

      FOR c_idiomes IN cur_idiomes LOOP
         INSERT INTO titulopro
                     (cramo, cmodali, ctipseg, ccolect, cidioma, ttitulo,
                      trotulo)
              VALUES (pcramo, pcmodali, pctipseg, pccolect, c_idiomes.cidioma, pttitulo,
                      ptrotulo);
      END LOOP;

      IF psproduc_copy IS NULL THEN
         --buscamos un producto del mismo ramo para copiar las configuraciones
         --relacionadas con el producto
         BEGIN
            SELECT MAX(sproduc)
              INTO vsproduc_copy
              FROM productos pp
             WHERE cramo = pcramo
               AND EXISTS(SELECT 1
                            FROM cfg_form
                           WHERE sproduc = pp.sproduc)
               AND EXISTS(SELECT 1
                            FROM cfg_wizard
                           WHERE sproduc = pp.sproduc);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               SELECT MAX(DISTINCT(sproduc))
                 INTO vsproduc_copy
                 FROM cfg_form;
         END;
      ELSE
         vsproduc_copy := psproduc_copy;
      END IF;

      vnumerr := f_duplica_cfg(vsproduc, vsproduc_copy, pparproductos);

/*Crearem temporalment una activitat per defecte, amb el mateix codi i nom que el producte,
quan el mnt d'activitats sigui ok s'haurà de treure. El mateix amb els documents
inici 27/09/2011 xpl
*/
      BEGIN
         BEGIN
            INSERT INTO codiactseg
                        (cramo, cactivi, cclarie, ccalif1, ccalif2)
                 VALUES (pcramo, vsproduc, 0, NULL, NULL);
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_MNTPRROD.codiactseg 1', NULL,
                           'Error al insertar en activiprod', SQLERRM);
         END;

         BEGIN
            INSERT INTO activisegu
                        (cidioma, cactivi, cramo, ttitulo, tactivi)
                 VALUES (2, vsproduc, pcramo, pttitulo, ptrotulo);
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_MNTPRROD.activisegu 1', NULL,
                           'Error al insertar en activisegu', SQLERRM);
         END;

         INSERT INTO activiprod
                     (cmodali, ccolect, ctipseg, cactivi, cramo, cactivo)
              VALUES (pcmodali, pccolect, pctipseg, vsproduc, pcramo, 1);
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_MNTPRROD.companipro 1', NULL,
                        'Error al insertar en activiprod', SQLERRM);
      END;

      BEGIN
         INSERT INTO prod_plant_cab
                     (sproduc, ctipo, ccodplan, imp_dest, fdesde, fhasta, cgarant, cduplica,
                      norden, clave, nrespue, tcopias)
            (SELECT vsproduc, ctipo, ccodplan, imp_dest, fdesde, fhasta, cgarant, cduplica,
                    norden, clave, nrespue, tcopias
               FROM prod_plant_cab
              WHERE sproduc = vsproduc_copy);
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_MNTPRROD.f_alta_producto 1', NULL,
                        'Error al insertar en PROD_PLANT_CAB', SQLERRM);
      END;

/* fi 27/09/2011 xpl */
      psproduc_out := vsproduc;
      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MNTPRROD.f_alta_producto 1', NULL,
                     'Error al insertar, ya existe el producto', SQLERRM);
         RETURN(100734);
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MNTPRROD.f_alta_producto 2', NULL,
                     'Error al insertar en la tabla productos', SQLERRM);
         RETURN(SQLERRM);
   END f_alta_producto;

       /*************************************************************************
         Función que actualiza los datos de la tabla GARANPRORED a partir
         del campo CGARPADRE de la tabla GARANPRO
         param in psproduc  : codigo del producto
         param in pcactivi  : codigo de la actividad
         param in pcgarant  : codigo de la garantia
         param in pfmovini  : fecha inicial del movimiento
         RETURN NUMBER (0.-Todo Ok; num_err si ha habido algun error)
   **********************************************************************/
   -- Bug 22049 - APD - 30/04/2012 - se crea la funcion
   FUNCTION f_act_garanprored(
      psproduc IN NUMBER DEFAULT NULL,
      pcactivi IN NUMBER DEFAULT NULL,
      pcgarant IN NUMBER DEFAULT NULL,
      pfmovini IN DATE DEFAULT f_sysdate)
      RETURN NUMBER IS
      vcgarant       NUMBER;
      vsproduc       NUMBER;
      vcactivi       NUMBER;
      vfmovini       DATE;
      vfmovfin       DATE;
      vfbaja         DATE;
      vg01           NUMBER;
      vg02           NUMBER;
      vg03           NUMBER;
      vcount         NUMBER;
      vpasexec       NUMBER;

      CURSOR c_garant(p_psproduc IN NUMBER, p_pcactivi IN NUMBER, p_pcgarant IN NUMBER) IS
         (SELECT sproduc, cactivi, cgarant, fmovini
            FROM garanprored
           WHERE sproduc = p_psproduc
             AND cactivi = p_pcactivi
             AND fmovfin IS NULL
             AND(g01 = p_pcgarant
                 OR g02 = p_pcgarant
                 OR g03 = p_pcgarant));
   BEGIN
      vpasexec := 1;

      FOR reg_g IN (SELECT sproduc, cactivi, cgarant
                      FROM garanpro
                     WHERE (sproduc = psproduc
                            OR psproduc IS NULL)
                       AND(cactivi = pcactivi
                           OR pcactivi IS NULL)
                       AND(cgarant = pcgarant
                           OR pcgarant IS NULL)) LOOP
         -- se mira si ya existe la garantia en garanprored
         SELECT COUNT(1)
           INTO vcount
           FROM garanprored
          WHERE sproduc = reg_g.sproduc
            AND cactivi = reg_g.cactivi
            AND cgarant = reg_g.cgarant
            AND fmovfin IS NULL;

         vpasexec := 2;

         IF vcount > 0 THEN   -- ya existe la garantia en garanprored
            vpasexec := 3;

            FOR i IN c_garant(reg_g.sproduc, reg_g.cactivi, reg_g.cgarant) LOOP
               vpasexec := 4;

               SELECT COUNT(1)
                 INTO vcount
                 FROM garanpro
                WHERE sproduc = i.sproduc
                  AND cactivi = i.cactivi
                  AND cgarant = i.cgarant;

               vpasexec := 5;

               IF vcount = 0 THEN   -- se ha eliminado la garantia
                  -- en un principio, cuando una garantia es eliminada de garanpro, no entrara nunca
                  -- por este codigo, sino por el cursor que hay más abajo que mira si hay alguna
                  -- garantia en garanprored que ya no exista en garanpro, pero se puede dejar este
                  -- codigo por si se da el caso (de todos modos, si entra por este codigo ya
                  -- no entra en el cursor de más abajo)
                  vpasexec := 6;

                  UPDATE garanprored
                     SET fmovfin = f_sysdate,
                         fbaja = f_sysdate
                   WHERE sproduc = i.sproduc
                     AND cactivi = i.cactivi
                     AND cgarant = i.cgarant
                     AND fmovini = i.fmovini;

                  vpasexec := 7;
               ELSE
                  vpasexec := 8;

                  FOR c IN (SELECT g.sproduc, g.cactivi, g.cgarant
                              FROM garanpro g
                             WHERE g.sproduc = i.sproduc
                               AND g.cactivi = i.cactivi
                               AND g.cgarant = i.cgarant) LOOP
                     vpasexec := 9;
                     vsproduc := c.sproduc;
                     vcactivi := c.cactivi;
                     vcgarant := c.cgarant;
                     vfmovini := pfmovini;
                     vfmovfin := NULL;
                     vfbaja := NULL;
                     vg01 := 0;
                     vg02 := 0;
                     vg03 := 0;
                     vpasexec := 10;

                     SELECT     COUNT(1)
                           INTO vcount
                           FROM garanpro g
                     START WITH cgarant = c.cgarant
                            AND sproduc = c.sproduc
                            AND cactivi = c.cactivi
                     CONNECT BY cgarant = PRIOR cgarpadre
                            AND sproduc = PRIOR sproduc
                            AND cactivi = PRIOR cactivi;

                     vpasexec := 11;

                     FOR rc IN (SELECT     g.sproduc, g.cactivi, g.cgarant,
                                           vcount + 1 - LEVEL tipo_gar
                                      FROM garanpro g
                                START WITH cgarant = c.cgarant
                                       AND sproduc = c.sproduc
                                       AND cactivi = c.cactivi
                                CONNECT BY cgarant = PRIOR cgarpadre
                                       AND sproduc = PRIOR sproduc
                                       AND cactivi = PRIOR cactivi) LOOP
                        vpasexec := 12;

                        IF rc.tipo_gar = 1 THEN
                           vg01 := rc.cgarant;
                        ELSIF rc.tipo_gar = 2 THEN
                           vg02 := rc.cgarant;
                        ELSIF rc.tipo_gar = 3 THEN
                           vg03 := rc.cgarant;
                        ELSE
                           NULL;
                        END IF;
                     END LOOP;

                     vpasexec := 13;

                     SELECT COUNT(1)
                       INTO vcount
                       FROM garanprored
                      WHERE sproduc = vsproduc
                        AND cactivi = vcactivi
                        AND cgarant = vcgarant
                        AND fmovfin IS NULL
                        AND(g01 <> vg01
                            OR g02 <> vg02
                            OR g03 <> vg03);

                     vpasexec := 14;

                     IF vcount <> 0 THEN
                        vpasexec := 15;

                        UPDATE garanprored
                           SET fmovfin = vfmovini
                         WHERE sproduc = vsproduc
                           AND cactivi = vcactivi
                           AND cgarant = vcgarant
                           AND fmovini = i.fmovini;

                        vpasexec := 16;

                        BEGIN
                           INSERT INTO garanprored
                                       (sproduc, cactivi, cgarant, fmovini, fmovfin,
                                        fbaja, g01, g02, g03)
                                VALUES (vsproduc, vcactivi, vcgarant, vfmovini, vfmovfin,
                                        vfbaja, vg01, vg02, vg03);

                           vpasexec := 17;
                        EXCEPTION
                           WHEN DUP_VAL_ON_INDEX THEN
                              vpasexec := 18;
                              NULL;
                        END;
                     END IF;

                     vpasexec := 19;
                  END LOOP;
               END IF;
            END LOOP;

            vpasexec := 20;

            -- si se elimina la garantia
            -- se busca en garanprored todas aquellas garantias que ya no existan en garanpro y
            -- que no se haya actualizado su fecha de baja
            FOR reg_grp IN (SELECT gpr.sproduc, gpr.cactivi, gpr.cgarant
                              FROM garanprored gpr
                             WHERE gpr.sproduc = reg_g.sproduc
                               AND gpr.cactivi = reg_g.cactivi
                               AND gpr.cgarant NOT IN(
                                      SELECT g.cgarant
                                        FROM garanpro g
                                       WHERE gpr.sproduc = g.sproduc
                                         AND gpr.cactivi = g.cactivi)
                               AND gpr.fbaja IS NULL) LOOP
               vpasexec := 21;

               UPDATE garanprored
                  SET fmovfin = f_sysdate,
                      fbaja = f_sysdate
                WHERE sproduc = reg_grp.sproduc
                  AND cactivi = reg_grp.cactivi
                  AND cgarant = reg_grp.cgarant;

               vpasexec := 22;
            END LOOP;
         ELSE   -- NO existe la garantia en garanprored (garantia nueva)
            vpasexec := 23;

            FOR c IN (SELECT g.sproduc, g.cactivi, g.cgarant
                        FROM garanpro g
                       WHERE g.sproduc = reg_g.sproduc
                         AND g.cactivi = reg_g.cactivi
                         AND g.cgarant = reg_g.cgarant) LOOP
               vpasexec := 24;
               vcgarant := c.cgarant;
               vsproduc := c.sproduc;
               vcactivi := c.cactivi;
               vfmovini := pfmovini;
               vfmovfin := NULL;
               vfbaja := NULL;
               vg01 := 0;
               vg02 := 0;
               vg03 := 0;
               vpasexec := 25;

               SELECT     COUNT(1)
                     INTO vcount
                     FROM garanpro g
               START WITH cgarant = c.cgarant
                      AND sproduc = c.sproduc
                      AND cactivi = c.cactivi
               CONNECT BY cgarant = PRIOR cgarpadre
                      AND sproduc = PRIOR sproduc
                      AND cactivi = PRIOR cactivi;

               vpasexec := 26;

               FOR rc IN (SELECT     g.sproduc, g.cactivi, g.cgarant,
                                     vcount + 1 - LEVEL tipo_gar
                                FROM garanpro g
                          START WITH cgarant = c.cgarant
                                 AND sproduc = c.sproduc
                                 AND cactivi = c.cactivi
                          CONNECT BY cgarant = PRIOR cgarpadre
                                 AND sproduc = PRIOR sproduc
                                 AND cactivi = PRIOR cactivi) LOOP
                  vpasexec := 27;

                  IF rc.tipo_gar = 1 THEN
                     vg01 := rc.cgarant;
                  ELSIF rc.tipo_gar = 2 THEN
                     vg02 := rc.cgarant;
                  ELSIF rc.tipo_gar = 3 THEN
                     vg03 := rc.cgarant;
                  ELSE
                     NULL;
                  END IF;
               END LOOP;

               vpasexec := 28;

               BEGIN
                  INSERT INTO garanprored
                              (sproduc, cactivi, cgarant, fmovini, fmovfin, fbaja,
                               g01, g02, g03)
                       VALUES (vsproduc, vcactivi, vcgarant, vfmovini, vfmovfin, vfbaja,
                               vg01, vg02, vg03);

                  vpasexec := 29;
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     vpasexec := 30;
                     NULL;
               END;
            END LOOP;
         END IF;
      END LOOP;

      vpasexec := 31;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_mntprod.f_act_garanprored', vpasexec, SQLCODE,
                     SQLERRM);
         RETURN 1000455;   -- Error no controlado.
   END f_act_garanprored;

   /*************************************************************************
            Función que retorna las duraciones de cobro de un producto
            param in psproduc  : codigo del producto

            RETURN sys_refcursor

            Bug 22253   17/05/2012   MDS
      **********************************************************************/
   FUNCTION f_get_durcobroprod(psproduc IN NUMBER)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(100) := 'PAC_MNTPROD.f_get_durcobroprod';
      vparam         VARCHAR2(400) := 'psproduc: ' || psproduc;
      cur            sys_refcursor;
   BEGIN
      OPEN cur FOR
         SELECT dr.ndurcob
           FROM durcobroprod dr, productos pr
          WHERE dr.cramo = pr.cramo
            AND dr.cmodali = pr.cmodali
            AND dr.ctipseg = pr.ctipseg
            AND dr.ccolect = pr.ccolect
            AND pr.sproduc = psproduc;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         p_tab_error(f_sysdate, f_user, vobjectname, 0, 'OTHERS cursor',
                     SQLERRM || ' ' || SQLCODE);
         RETURN cur;
   END f_get_durcobroprod;

   /**************************************************************************
     Assigna un pla de pensió per un producte. Si existe, lo actualiza
     param in psproduc     : Codigo del producto
     param in pccodpla    : Codigo del plan de pensión
   **************************************************************************/
   FUNCTION f_set_planpension(psproduc IN NUMBER, pccodpla IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      ---insersió-----------
      INSERT INTO proplapen
                  (sproduc, ccodpla)
           VALUES (psproduc, pccodpla);

      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         UPDATE proplapen
            SET ccodpla = pccodpla
          WHERE sproduc = psproduc;

         RETURN 0;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MNTPRROD.f_set_planpension', NULL,
                     'Error al insertar en la tabla proplapen', SQLERRM);
         RETURN(1000052);   --Error general
   END f_set_planpension;

   /**************************************************************************
   función que graba el modelo recibido por parámetro para un idioma.
   param in pcramo     :
   param in pccolect    :
   param in pcmodali    :
   param in pctipseg    :
   param in pcmodinv    :
   param in ptmodinv    :
   param in out mensajes    :
   **************************************************************************/
   FUNCTION f_set_modelinv(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pccolect IN NUMBER,
      pctipseg IN NUMBER,
      pcmodinv IN NUMBER,
      pcidioma IN NUMBER,
      ptmodinv IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      nerror         NUMBER;
   BEGIN
      BEGIN
         INSERT INTO modelosinversion
                     (cramo, cmodali, ctipseg, ccolect, cmodinv, finicio, ffin)
              VALUES (pcramo, pcmodali, pctipseg, pccolect, pcmodinv, f_sysdate, NULL);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            nerror := 0;
      END;

      BEGIN
         INSERT INTO codimodelosinversion
                     (cidioma, tmodinv, cramo, cmodali, ctipseg, ccolect, cmodinv)
              VALUES (pcidioma, ptmodinv, pcramo, pcmodali, pctipseg, pccolect, pcmodinv);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE codimodelosinversion
               SET tmodinv = ptmodinv
             WHERE cramo = pcramo
               AND cmodali = pcmodali
               AND cmodinv = pcmodinv
               AND ctipseg = pctipseg
               AND ccolect = pccolect
               AND cidioma = pcidioma;
      END;

      COMMIT;
      RETURN 0;
   END f_set_modelinv;

   /**************************************************************************
    función que graba el fondo correspondiente a  un modelo de inversión recibido por parámetro para un idioma.
    param in psproduc     :
    param in pccodfon    :
    param in pinvers    :
    param in pmaxcont    :
    param in out mensajes    :
    **************************************************************************/
   FUNCTION f_set_modinvfondo(
      psproduc IN NUMBER,
      pccodfon IN NUMBER,
      ppinvers IN NUMBER,
      pcmodinv IN NUMBER,
      ppmaxcont IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      vobject        VARCHAR2(30) := 'PAC_MNTPROD.f_set_modinvfonfo';
      vpasexec       NUMBER;
      vparam         VARCHAR2(100)
         :=(psproduc || '#' || pccodfon || '#' || ppinvers || '#' || pcmodinv || '#'
            || ppmaxcont);
   BEGIN
      vpasexec := 1;

      SELECT cramo, cmodali, ctipseg, ccolect
        INTO vcramo, vcmodali, vctipseg, vccolect
        FROM productos
       WHERE sproduc = psproduc;

      vpasexec := 2;

      BEGIN
         INSERT INTO modinvfondo
                     (ccodfon, pinvers, cramo, cmodali, ctipseg, ccolect, cmodinv,
                      pmaxcont)
              VALUES (pccodfon, ppinvers, vcramo, vcmodali, vctipseg, vccolect, pcmodinv,
                      ppmaxcont);

         COMMIT;
         RETURN 0;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE modinvfondo
               SET pinvers = ppinvers,
                   pmaxcont = ppmaxcont
             WHERE ccodfon = pccodfon
               AND cmodinv = pcmodinv
               AND cramo = vcramo
               AND cmodali = vcmodali
               AND ctipseg = vctipseg;

            COMMIT;
            RETURN 0;
      END;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 1000005;
      WHEN OTHERS THEN
         RETURN 1000001;
   END f_set_modinvfondo;

   /**************************************************************************
     función que borra el fondo correspondiente a  un modelo de inversión recibido por parámetro
     param in pccodfon    :
     param in pinvers    :
     param in out mensajes    :
     **************************************************************************/
   FUNCTION f_del_modinvfondos(
      pccodfon IN NUMBER,
      pcmodinv IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
   BEGIN
      DELETE FROM modinvfondo
            WHERE ccodfon = pccodfon
              AND cmodinv = pcmodinv;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 1000001;
   END f_del_modinvfondos;

   /*************************************************************************
         Funci¿n que busca en la tabla int_codigos_emp
         PARAM IN CCODIGO     : codigo de la interfaz
         PARAM IN CVALAXIS    : valor del campo en axis
         PARAM IN CVALEMP    : valor del campo en la empresa
         PARAM OUT MENSAJES   : mensajes de error

         RETURN NUMBER

         Bug 15023   01/11/2013  LPP
   **********************************************************************/
   FUNCTION f_get_interficie(
      pccodigo IN VARCHAR2,
      pcvalaxis IN VARCHAR2,
      pcvalemp IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_interficies IS
      CURSOR c_cods IS
         SELECT *
           FROM int_codigos_emp
          WHERE ccodigo = NVL(pccodigo, ccodigo)
            AND cempres = pac_md_common.f_get_cxtempresa
            AND cvalemp = NVL(pcvalemp, cvalemp)
            AND cvalaxis = NVL(pcvalaxis, cvalaxis);

      o_interf       ob_iax_interficies;
      t_interf       t_iax_interficies := t_iax_interficies();
   BEGIN
      FOR r_cods IN c_cods LOOP
         o_interf := ob_iax_interficies();
         o_interf.ccodigo := r_cods.ccodigo;
         o_interf.cvalaxis := r_cods.cvalaxis;
         o_interf.cvalemp := r_cods.cvalemp;
         o_interf.cvaldef := r_cods.cvaldef;
         o_interf.cvalaxisdef := r_cods.cvalaxisdef;
         t_interf.EXTEND;
         t_interf(t_interf.LAST) := o_interf;
      END LOOP;

      RETURN t_interf;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MNTPRROD.f_get_interficie', NULL,
                     'Error al recuperar de la tabla INT_CODIGOS_EMP', SQLERRM);
   END f_get_interficie;

   /*************************************************************************
         Funci¿n que mantiene la tabla int_codigos_emp
         PARAM IN CCODIGO     : codigo de la interfaz
         PARAM IN CVALAXIS    : valor del campo en axis
         PARAM IN CVALEMP    : valor del campo en la empresa
         PARAM IN CVALDEF    : valor del campo en axis, por si cvalaxis tiene mas de un valor
         PARAM IN CVALAXISDEF : valor del campo en la empresa, por si cvalaxisdef tiene mas de un valor
         PARAM OUT MENSAJES   : mensajes de error

         RETURN NUMBER

         Bug 15023   01/11/2013  LPP
   **********************************************************************/
   FUNCTION f_set_interficie(
      pccodigo IN VARCHAR2,
      pcvalaxis IN VARCHAR2,
      pcvalemp IN VARCHAR2,
      pcvaldef IN VARCHAR2,
      pcvalaxisdef IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      n_cods         NUMBER;
   BEGIN
      SELECT COUNT('g')
        INTO n_cods
        FROM int_codigos_emp
       WHERE ccodigo = pccodigo
         AND cempres = pac_md_common.f_get_cxtempresa
         AND cvalaxis = pcvalaxis;

      IF n_cods = 0 THEN
         INSERT INTO int_codigos_emp
                     (ccodigo, cempres, cvalaxis, cvalemp,
                      cvaldef, cvalaxisdef)
              VALUES (pccodigo, pac_md_common.f_get_cxtempresa, pcvalaxis, pcvalemp,
                      pcvaldef, pcvalaxisdef);
      ELSE
         UPDATE int_codigos_emp
            SET cvalemp = pcvalemp,
                cvaldef = pcvaldef,
                cvalaxisdef = pcvalaxisdef
          WHERE ccodigo = pccodigo
            AND cempres = pac_md_common.f_get_cxtempresa
            AND cvalaxis = pcvalaxis;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MNTPRROD.f_set_interficie', NULL,
                     'Error al insertar en la tabla INT_CODIGOS_EMP', SQLERRM);
         RETURN(1000052);   --Error general
   END f_set_interficie;

   /*************************************************************************
         Funci¿n que borra de la tabla int_codigos_emp
         PARAM IN CCODIGO     : codigo de la interfaz
         PARAM IN CVALAXIS    : valor del campo en axis
         PARAM OUT MENSAJES   : mensajes de error

         RETURN NUMBER

         Bug 15023   01/11/2013  LPP
   **********************************************************************/
   FUNCTION f_del_interficie(
      pccodigo IN VARCHAR2,
      pcvalaxis IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
   BEGIN
      DELETE      int_codigos_emp
            WHERE ccodigo = pccodigo
              AND cempres = pac_md_common.f_get_cxtempresa
              AND cvalaxis = pcvalaxis;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MNTPRROD.f_del_interficie', NULL,
                     'Error al insertar en la tabla INT_CODIGOS_EMP', SQLERRM);
         RETURN(1000052);   --Error general
   END f_del_interficie;
END pac_mntprod;

/

  GRANT EXECUTE ON "AXIS"."PAC_MNTPROD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MNTPROD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MNTPROD" TO "PROGRAMADORESCSI";
