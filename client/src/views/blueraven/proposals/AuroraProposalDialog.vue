<script setup>
/*
*@name AuroraProposalDialog
*@author jess
*@date 9/24/24
*
*@description
*
*/
import CustomValueInput from "@/views/flow/components/CustomValueInput.vue";
import {computed, defineEmits, onMounted, ref} from "vue";
import {ProposalCFGAIDs, YearlyConsumptionCalcListOfValueId} from "@/views/blueraven/proposals/ProposalCFGAIDEnum.js";
import constants from "@/helpers/constants.js";
import ConfirmationDialog from "@/components/ConfirmationDialog.vue";

const props = defineProps({
  show: {
    type: Boolean,
    default: false
  },
  aiRequestFields:Array,
  savingNewAiDesign:{
    type: Boolean,
    default: false
  }
})
const emit = defineEmits(['close', 'save'])
const squareFootage = ref(null)
const aiForm = ref(null)
const requiredRules = constants.BASIC_REQUIRED_RULE
const months = constants.MONTHS
const monthlyUsage = ref([])
const disabledMonthIds = ref([])
const showMinMonthsError = ref(false)

const calculatedBy = computed(() => {
  return props.aiRequestFields.find(field => field.customFieldGroupAssignmentId === ProposalCFGAIDs.HOW_WAS_YEARLY_CONSUMPTION_CALC)
})

const calculatedByIsSet = computed(() => {
  return !!calculatedBy.value?.intValue;
})

const calcEnergyBySqFtg = computed(() => {
  return calculatedBy.value?.intValue === YearlyConsumptionCalcListOfValueId.SQUARE_FOOTAGE
})

const validateAIRequest = async () => {
  const valid = aiForm.value.validate() && validMonthlyData()
  if (valid) {
    //all checks for how to create the design are handled by backend now
    emit('save', monthlyUsageFlattened.value)
  }
  else if(!minMonthsFilled.value){
    showMinMonthsError.value = true
  }
}

const monthlyUsageFlattened = computed(() =>{
  /* if we're calculating the energy by the square footage, we still need a monthly array with 12 values
  the monthly array will currently have one value equal to the yearly divided by 12, we just need to use that
  same value twelve times
   */
  const populated = []
  if(calcEnergyBySqFtg.value){
    for(let i = 0; i < 12; i++){
      populated.push(monthlyUsage.value[0].usage)
    }
  }
  /* If we're inputting monthly values from the utility bill, they want us to do it in Aurora, not here.
   */
  else {
   return null
  }
return populated
})

const utilityCoId = computed(() => {
  const utilityCoField = props.aiRequestFields.find(f => f.customFieldGroupAssignmentId === ProposalCFGAIDs.UTILITY_CO)
  return utilityCoField?.intValue
  //todo: recalculate usage when utility changes if calcEnergyBySqFtg
})

//Utility Bill Option
const addMonthUsage = (usage, monthId) =>{
  //make sure we don't add a duplicate if they change a value or clear a value
  const existingUsageIndex = monthlyUsage.value.findIndex(mu => mu.monthId === monthId)
  if(existingUsageIndex >= 0){
    monthlyUsage.value.splice(existingUsageIndex,1)
  }
  //if the usage is "", they cleared the field
  if(usage !== "") {
    monthlyUsage.value.push({
      monthId: monthId,
      usage: Number(usage)
    })
  }
  updateDisabledMonths()
}

const updateDisabledMonths = (() =>{
  if(maxMonthsFilled() || monthsOverFilled()){
    months.forEach(m => {
      const existingUsage = monthlyUsage.value.find(mu =>  mu.monthId === m.id)
      if(!existingUsage){
        disabledMonthIds.value.push(m.id);
      }
    })
  }
  else{
      disabledMonthIds.value = []
  }
})

const maxMonthsFilled = (() => {
  //if the calculation method hasn't been selected yet, there is no max months
  if(!calculatedBy.value?.intValue){
    return false
  }
  switch (calculatedBy.value?.intValue) {
    case YearlyConsumptionCalcListOfValueId.MONTHS_12_ABOVE:
      return false;
    case YearlyConsumptionCalcListOfValueId.MONTHS_8_11:
      return monthlyUsage.value.length === 11;
    case YearlyConsumptionCalcListOfValueId.MONTHS_4_7:
      return monthlyUsage.value.length === 7;
    case YearlyConsumptionCalcListOfValueId.MONTHS_4_BELOW:
      return monthlyUsage.value.length === 3;
    default:
      return false;
  }
})

const validMonthlyData = (() => {
  if(calcEnergyBySqFtg.value){
    return monthlyUsage.value?.length > 0
  } else {
    return true
  }
})

const monthsOverFilled = (() => {
  //if the calculation method hasn't been selected yet, there is no max months
  if(!calculatedBy.value?.intValue){
    return false
  }
  switch (calculatedBy.value?.intValue) {
    case YearlyConsumptionCalcListOfValueId.MONTHS_12_ABOVE:
      return false;
    case YearlyConsumptionCalcListOfValueId.MONTHS_8_11:
      return monthlyUsage.value.length > 11;
    case YearlyConsumptionCalcListOfValueId.MONTHS_4_7:
      return monthlyUsage.value.length > 7;
    case YearlyConsumptionCalcListOfValueId.MONTHS_4_BELOW:
      return monthlyUsage.value.length > 3;
    default:
      return false;
  }
})

const minMonths = computed(()=>{
  //if the calculation method hasn't been selected yet, there is no min months
  if(!calculatedBy.value?.intValue){
    return 0
  }
  switch (calculatedBy.value?.intValue) {
    case YearlyConsumptionCalcListOfValueId.MONTHS_12_ABOVE:
      return 12;
    case YearlyConsumptionCalcListOfValueId.MONTHS_8_11:
      return 8;
    case YearlyConsumptionCalcListOfValueId.MONTHS_4_7:
      return  4;
    case YearlyConsumptionCalcListOfValueId.MONTHS_4_BELOW:
    default:
      return 1;
  }
})

const minMonthsFilled = computed(() => {
  return monthlyUsage.value.length >= minMonths.value
})


// Square Footage Option
const calculateUsage = (field) => {
  const squareFootage = Number(field.textValue)
  const yearlyConsumptionField = props.aiRequestFields.find(cf => cf.customFieldGroupAssignmentId === ProposalCFGAIDs.ESTIMATED_ANNUAL_CONSUMPTION)
  //pass in the correct enum to the energyUsage function; this works because they all use the same names
  switch (utilityCoId.value) {
    case null:
      yearlyConsumptionField.intValue = null
      break;
    case 232: //Xcel Energy
      yearlyConsumptionField.intValue = energyUsage(squareFootage, xcelEnergyValues)
          break;
    case 383: //Xcel Eneregy MN
      yearlyConsumptionField.intValue = energyUsage(squareFootage, xcelEnergyMNValues)
          break;
    default:
      yearlyConsumptionField.intValue = energyUsage(squareFootage, defaultEnergyValues)
          break;
  }
  monthlyUsage.value = [{
    usage: Math.round(yearlyConsumptionField.intValue / 12)
  }]
}

const updateEnergyUsageValues = (event) =>{
  //if the utility company changes when we're calculating by square footage, we need to recalculate the energy usage
  if(event.customFieldGroupAssignmentId === ProposalCFGAIDs.UTILITY_CO && calcEnergyBySqFtg.value){
    const sqFtField = props.aiRequestFields.find(cf => cf.customFieldGroupAssignmentId === ProposalCFGAIDs.SQUARE_FOOTAGE)
    calculateUsage(sqFtField)
  }
  //if the field for HOW_WAS_YEARLY_CONSUMPTION_CALC was changed, we should clear out all the fields related to energy usage
  if(event.customFieldGroupAssignmentId === ProposalCFGAIDs.HOW_WAS_YEARLY_CONSUMPTION_CALC) {
    props.aiRequestFields.forEach(cf => {
      if (cf.customFieldGroupAssignmentId === ProposalCFGAIDs.ESTIMATED_ANNUAL_CONSUMPTION || cf.customFieldGroupAssignmentId === ProposalCFGAIDs.SQUARE_FOOTAGE) {
        cf.intValue = null
        cf.textValue = null
      }
    })
    updateDisabledMonths()
  }
}

const energyUsage = (sqft, energyEstimates) =>{
  switch (true){
    case sqft <=500:
      return energyEstimates.MAX500
    case 500 < sqft && sqft <= 1000:
      return energyEstimates.MAX1000
    case 1000 < sqft && sqft <= 1500:
      return energyEstimates.MAX1500
    case 1500 < sqft && sqft <=2000:
      return energyEstimates.MAX2000
    case 2000 < sqft && sqft <=2500:
      return energyEstimates.MAX2500
    case 2500 < sqft && sqft <= 3000:
      return energyEstimates.MAX3000
    case 3000 < sqft && sqft <=3500:
      return energyEstimates.MAX3500
    case 3500 < sqft && sqft <=4000:
      return energyEstimates.MAX4000
    case 4000 < sqft && sqft <=20000:
    default:
      return energyEstimates.MAX20000
  }
}

/*
The values below came from charts provided by Blue Raven
* If we need to support another company, we will probably need to put these in the database
*/
const defaultEnergyValues = Object.freeze({
  MAX500:3999,
  MAX1000: 5685,
  MAX1500: 7589,
  MAX2000:9166,
  MAX2500: 10541,
  MAX3000: 11365,
  MAX3500: 12500,
  MAX4000: 13634,
  MAX20000: 15569
})
const xcelEnergyValues = Object.freeze({
  MAX500:3199,
  MAX1000: 4548,
  MAX1500: 6071,
  MAX2000:7333,
  MAX2500: 8433,
  MAX3000: 9092,
  MAX3500: 10000,
  MAX4000: 10907,
  MAX20000: 12455
})
const xcelEnergyMNValues = Object.freeze({
  MAX500:3656,
  MAX1000: 4426,
  MAX1500: 6098,
  MAX2000:8513,
  MAX2500: 9182,
  MAX3000: 10815,
  MAX3500: 13015,
  MAX4000: 12358,
  MAX20000: 14906
})
</script>

<template>
  <ConfirmationDialog :width="500"
                      persistent
                      :open-dialog="show"
                      parent-close
                      :confirm-loading="savingNewAiDesign"
                      @confirm="validateAIRequest"
                      @close-dialog="emit('close')" >
      <template v-slot:title>Create New AI Design</template>
    <template v-slot:yes>Save</template>
        <v-form ref="aiForm">
          <div v-for="(cf, idx) in aiRequestFields" :key="idx">
            <!--              <div>{{cf}}</div>-->
            <div v-if="cf.customFieldGroupAssignmentId === ProposalCFGAIDs.SQUARE_FOOTAGE && calcEnergyBySqFtg">
                <div v-if="!utilityCoId" class="error--text">Please select a utility company to calculate the annual and monthly energy usage.</div>
                <CustomValueInput
                    :field="cf"
                    :show-field-name="false"
                    :value="squareFootage"
                    :required="calcEnergyBySqFtg"
                    :readonly="savingNewAiDesign || !utilityCoId"
                    :callback="calculateUsage"
                    custom-class="albatross-body-2"
                >5432
                </CustomValueInput>
            </div>
              <div v-else-if="cf.customFieldGroupAssignmentId === ProposalCFGAIDs.ESTIMATED_ANNUAL_CONSUMPTION && calcEnergyBySqFtg">
                <div class="label-large">Energy Usage</div>
                <div class="body-large"><span class="label-medium">Annual: </span><span v-if="!!cf.intValue">{{cf.intValue}} kWh</span></div>
                <div class="body-large"><span class="label-medium">Monthly: </span><span v-if="!!cf.intValue">{{monthlyUsage[0]?.usage}} kWh</span></div>
              </div>
              <div v-else-if="cf.customFieldGroupAssignmentId === ProposalCFGAIDs.ESTIMATED_ANNUAL_CONSUMPTION && calculatedByIsSet && !calcEnergyBySqFtg">
                <v-card class="label-medium pa-0" flat>
                 <v-card-title class="pa-0">Please Enter Usage through Aurora.</v-card-title>
                  <v-card-text class="pa-0">You will be redirected to Aurora after saving.</v-card-text>
                </v-card>

              </div>

            <CustomValueInput
                v-else-if="cf.customFieldGroupAssignmentId !== ProposalCFGAIDs.SQUARE_FOOTAGE && cf.customFieldGroupAssignmentId !== ProposalCFGAIDs.ESTIMATED_ANNUAL_CONSUMPTION"
                :show-field-name="false"
                :required="true"
                :callback="updateEnergyUsageValues"
                custom-class="albatross-body-2"
                :field="cf"
                :custom-label="cf.customFieldGroupAssignmentId === ProposalCFGAIDs.HOW_WAS_YEARLY_CONSUMPTION_CALC ? 'How should yearly consumption be calculated?' : null"
                :readonly="savingNewAiDesign"
            ></CustomValueInput>
            <div v-if="cf.customFieldGroupAssignmentId === ProposalCFGAIDs.HOW_WAS_YEARLY_CONSUMPTION_CALC && cf.intValue === 22778" class="error-text pb-2">If you have less than 4 months of usage data, you should use the Square footage instead.</div>
          </div>
        </v-form>
  </ConfirmationDialog>

</template>

<style scoped lang="scss">

</style>
