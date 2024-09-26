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

const validateAIRequest = async () => {
  debugger
  const valid = aiForm.value.validate()
  if (valid) {
    //all checks for how to create the design are handled by backend now
    emit('save', aiForm.value)
  }
}



const calcMethodText = computed(() => {
  if(calcEnergyBySqFtg.value){
    return 'Calculate Energy by Square Footage'
  } else {
    return 'Enter usage from utility bill into Aurora Sales Mode'
  }
})

const toggleCalcMethod = (field) => {
  if(!calcEnergyBySqFtg.value) {
    squareFootage.value = null

    //
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

const calculateUsage = (sqft, field) => {
  const squareFootage = Number(sqft)
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
  <ConfirmationDialog :width="500" persistent :open-dialog="show" parent-close @confirm="validateAIRequest" @close-dialog="emit('close')">
      <template v-slot:title>Create New AI Design</template>
    <template v-slot:yes>Save</template>
        <v-form ref="aiForm">
          <div v-for="(cf, idx) in aiRequestFields" :key="idx">
            <!--              <div>{{cf}}</div>-->
            <div v-if="cf.customFieldGroupAssignmentId === ProposalCFGAIDs.ESTIMATED_ANNUAL_CONSUMPTION">
                <v-radio-group label="Energy Usage" v-model="calcEnergyBySqFtg">
                <v-radio :value="true" label="Calculate Energy by Square Footage"></v-radio>
                <v-radio :value="false" label="Utility Bill"></v-radio>
              </v-radio-group>
              <div v-if="calcEnergyBySqFtg">
                <a-text-field type="number"
                              density="compact"
                              label="Enter Square Footage"
                              :value="squareFootage"
                              :rules="calcEnergyBySqFtg ? [...requiredRules] : null"
                              @change="calculateUsage($event, cf)"
                >
                </a-text-field>
                <div class="body-large"><span class="label-medium">Annual: </span><span v-if="!!cf.intValue">{{cf.intValue}} kWh</span></div>
                <div class="body-large"><span class="label-medium">Monthly: </span><span v-if="!!cf.intValue">{{cf.intValue / 12}} kWh</span></div>
              </div>
              <div v-else>
                <v-card class="label-medium pa-0" flat>
                  <v-card-title class="pa-0">Enter usage from utility bill
                    <a-btn size="small" icon class="ml-1"><v-icon small>mdi-plus-circle-outline</v-icon></a-btn>
                  </v-card-title>
                <v-row class="pt-0">
                  <v-col cols="3" class="pt-0">
                  <a-select label="Month" :items="months" item-title="name" item-value="id"></a-select>
<!--                    todo: object array [{monthId, usage}], add a select for each object in this array and add another object every time you press the + button
                        filter the months available in the select to remove any months that have already been used
-->
                  </v-col>
                  <v-col cols="3" class="pt-0">
                    <a-text-field label="Usage"></a-text-field>
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
            ></CustomValueInput>
          </div>
        </v-form>
  </ConfirmationDialog>

</template>

<style scoped lang="scss">

</style>
