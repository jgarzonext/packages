--------------------------------------------------------
--  DDL for Package Body PAC_MNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MNT" IS
------------------------------------------------------------------------------------------
   FUNCTION f_ins_empresas(
      pcempres IN NUMBER,
      pctipemp IN NUMBER,
      psperson IN NUMBER,
      ptempres IN VARCHAR2,
      pnnumnif IN VARCHAR2,
      piminliq IN NUMBER,
      pncarenc IN NUMBER,
      pncardom IN NUMBER)
      RETURN NUMBER IS
   /***********************************************************************************
   Función que realiza el insert en la tabla empresas.
   Paràmetres :
             Parámetro  Data Type   IN / OUT DEFAULT  DESCRIPCIÓN
             PCEMPRES   NUMBER           IN     Código de empresa
             PCTIPEMP   NUMBER           IN     Tipo de empresa
             PSPERSON     NUMBER          IN     Identificador de persona
             PTEMPRES     VARCHAR2       IN      Nombre de la empresa
             PNNUMNIF     VARCHAR2       IN      CIF de la empresa
             PIMINLIQ     NUMBER          IN     Importe mínimo de liquidación de agentes
             PNCARENC     NUMBER          IN     Días de carencia de liquidación
             PNCARDOM     NUMBER          IN     Días de carencia de domiciliación
   ***********************************************************************************/
   BEGIN
      INSERT INTO empresas
                  (cempres, ctipemp, sperson, tempres, nnumnif, iminliq, ncarenc,
                   ncardom)
           VALUES (pcempres, pctipemp, psperson, ptempres, pnnumnif, piminliq, pncarenc,
                   pncardom);

      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         RETURN 102535;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_mnt.f_ins_empresas', 1,
                     'when others pcempres =' || pcempres, SQLERRM);
         RETURN 102530;
   END f_ins_empresas;

   FUNCTION f_update_empresas(
      pcempres IN NUMBER,
      pctipemp IN NUMBER,
      psperson IN NUMBER,
      ptempres IN VARCHAR2,
      pnnumnif IN VARCHAR2,
      piminliq IN NUMBER,
      pncarenc IN NUMBER,
      pncardom IN NUMBER)
      RETURN NUMBER IS
      /***********************************************************************************
        Función que realiza el update en la tabla empresas.
        Paràmetres :
             Parámetro  Data Type   IN / OUT DEFAULT  DESCRIPCIÓN
             PCEMPRES   NUMBER           IN     Código de empresa
             PCTIPEMP   NUMBER           IN     Tipo de empresa
             PSPERSON     NUMBER          IN     Identificador de persona
             PTEMPRES     VARCHAR2       IN      Nombre de la empresa
             PNNUMNIF     VARCHAR2       IN      CIF de la empresa
             PIMINLIQ     NUMBER          IN     Importe mínimo de liquidación de agentes
             PNCARENC     NUMBER          IN     Días de carencia de liquidación
             PNCARDOM     NUMBER          IN     Días de carencia de domiciliación
   ***********************************************************************************/
   BEGIN
      UPDATE empresas
         SET ctipemp = pctipemp,
             sperson = psperson,
             tempres = ptempres,
             nnumnif = pnnumnif,
             iminliq = piminliq,
             ncarenc = pncarenc,
             ncardom = pncardom
       WHERE cempres = pcempres;

      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         RETURN 102535;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_mnt.f_update_empresas', 1,
                     'when others pcempres =' || pcempres, SQLERRM);
         RETURN 102531;
   END f_update_empresas;

   FUNCTION f_del_empresas(pcempres IN NUMBER)
      RETURN NUMBER IS
   /***********************************************************************************
   Función que realiza el delete en la tabla empresas.
   Paràmetres :
             Parámetro  Data Type   IN / OUT DEFAULT  DESCRIPCIÓN
             PCEMPRES   NUMBER           IN     Código de empresa
   ***********************************************************************************/
   BEGIN
      IF pcempres IS NOT NULL THEN
         DELETE FROM empresas
               WHERE cempres = pcempres;

         RETURN 0;
      ELSE
         RETURN 103870;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_mnt.f_del_empresas', 1,
                     'when others pcempres =' || pcempres, SQLERRM);
         RETURN 103870;
   END f_del_empresas;
END;
--/

/

  GRANT EXECUTE ON "AXIS"."PAC_MNT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MNT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MNT" TO "PROGRAMADORESCSI";
