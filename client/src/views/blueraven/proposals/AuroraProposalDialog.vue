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
import {computed, defineEmits, ref} from "vue";
import {ProposalCFGAIDs} from "@/views/blueraven/proposals/ProposalCFGAIDEnum.js";
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
const calcEnergyBySqFtg = ref(true)
const squareFootage = ref(null)
const aiForm = ref(null)
const requiredRules = constants.BASIC_REQUIRED_RULE
const months = constants.MONTHS
const monthlyUsage = ref([])

const validateAIRequest = async () => {
  const valid = aiForm.value.validate() && monthlyUsage.value?.length > 0
  if (valid) {
    //all checks for how to create the design are handled by backend now
    emit('save', monthlyUsageFlattened.value)
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
  /* If we're inputting monthly values from the utility bill, we need to flatten them to an array of numbers (they're currently an object)
    in order January-December.  Since they could have been added in any order, we need to sort them before we flatten them.
   */
  else {
    for(let i = 0; i < 12; i++){
      const usageForMonth = monthlyUsage.value.find( mu => mu.monthId === i + 1)
      populated.push(usageForMonth ? usageForMonth.usage : null)
    }
  }
return populated
})

const toggleCalcMethod = (field) => {
  //todo: call this when we switch between the two radio buttons
  if(!calcEnergyBySqFtg.value) {
    squareFootage.value = null
  } else {

  }
  field.intValue = null
  calcEnergyBySqFtg.value = !calcEnergyBySqFtg.value
}

const utilityCoId = computed(() => {
  const utilityCoField = props.aiRequestFields.find(f => f.customFieldGroupAssignmentId === ProposalCFGAIDs.UTILITY_CO)
  return utilityCoField?.intValue
  //todo: recalculate usage when utility changes if calcEnergyBySqFtg
})

//Utility Bill Option
const addMonthUsage = (usage, monthId) =>{
  //make sure we don't add a duplicate if they change a value or clear a value
  const existingUsageIndex = monthlyUsage.value.indexOf(mu => mu.monthId === monthId)
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
}


// Square Footage Option
const calculateUsage = (sqft, field) => {
  const squareFootage = Number(sqft)
  //pass in the correct enum to the energyUsage function; this works because they all use the same names
  switch (utilityCoId.value) {
    case 232: //Xcel Energy
      field.intValue = energyUsage(squareFootage, xcelEnergyValues)
          break;
    case 383: //Xcel Eneregy MN
      field.intValue = energyUsage(squareFootage, xcelEnergyMNValues)
          break;
    default:
      field.intValue = energyUsage(squareFootage, defaultEnergyValues)
          break;
  }
  monthlyUsage.value = [{
    usage: Math.round(field.intValue / 12)
  }]
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
            <div v-if="cf.customFieldGroupAssignmentId === ProposalCFGAIDs.ESTIMATED_ANNUAL_CONSUMPTION">
                <v-radio-group label="Energy Usage" v-model="calcEnergyBySqFtg" :disabled="savingNewAiDesign">
                <v-radio :value="true" label="Calculate Energy by Square Footage"></v-radio>
                <v-radio :value="false" label="Utility Bill"></v-radio>
              </v-radio-group>
              <div v-if="calcEnergyBySqFtg">
                <a-text-field type="number"
                              density="compact"
                              label="Enter Square Footage"
                              :value="squareFootage"
                              :rules="calcEnergyBySqFtg ? [...requiredRules] : null"
                              :disabled="savingNewAiDesign"
                              @change="calculateUsage($event, cf)"
                >
                </a-text-field>
                <div class="body-large"><span class="label-medium">Annual: </span><span v-if="!!cf.intValue">{{cf.intValue}} kWh</span></div>
                <div class="body-large"><span class="label-medium">Monthly: </span><span v-if="!!cf.intValue">{{monthlyUsage[0]?.usage}} kWh</span></div>
              </div>
              <div v-else>
                <v-card class="label-medium pa-0" flat>
                  <v-card-title class="pa-0">Enter usage from utility bill
                  </v-card-title>
                <v-row class="pt-0">
                  <v-col v-for="(month, index) in months" cols="3" class="pt-0">
                    <a-text-field density="dense" type="number" :label="`${month.name}`" @change="addMonthUsage($event, month.id)" :disabled="savingNewAiDesign"></a-text-field>
                  </v-col>
                </v-row>
                </v-card>

              </div>

            </div>
            <CustomValueInput
                v-else
                :show-field-name="false"
                :required="true"
                @change=""
                custom-class="albatross-body-2"
                :field="cf"
                :readonly="savingNewAiDesign"
            ></CustomValueInput>
          </div>
        </v-form>
  </ConfirmationDialog>

</template>

<style scoped lang="scss">

</style>
