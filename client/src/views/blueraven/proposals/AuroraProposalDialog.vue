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


const calcMethodText = computed(() => {
  if(calcEnergyBySqFtg.value){
    return 'Calculate Energy by Square Footage'
  } else {
    return 'Calculate Energy by Utility Bill'
  }
})

const toggleCalcMethod = () => {
  if(!calcEnergyBySqFtg.value) {
    //
  } else {

  }
  calcEnergyBySqFtg.value = !calcEnergyBySqFtg.value
}

const utilityCoId = computed(() => {
  const utilityCoField = props.aiRequestFields.find(f => f.customFieldGroupAssignmentId === ProposalCFGAIDs.UTILITY_CO)
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
  <v-dialog width="500" persistent v-model="show">
    <v-card>
      <v-card-title>Create New AI Design</v-card-title>
      <v-card-text class="default-text-color">
        <v-form ref="aiForm">
          <div v-for="(cf, idx) in aiRequestFields" :key="idx">
            <!--              <div>{{cf}}</div>-->
            <div v-if="cf.customFieldGroupAssignmentId === ProposalCFGAIDs.ESTIMATED_ANNUAL_CONSUMPTION">
              <div class="label-large">{{ calcMethodText }}
                <a-btn
                    color="primary"
                    class="mb-4 text-capitalize"
                    @click="toggleCalcMethod"
                    size="small"
                    text="Change Energy Calculation Method"
                ></a-btn>
                <a-text-field v-if="calcEnergyBySqFtg"
                    class="mt-0"
                              type="number"
                              label="Enter Square Footage"
                              :value="squareFootage"
                              @change="calculateUsage($event, cf)"
                >

                </a-text-field>
              </div>
            </div>
            <CustomValueInput
                :show-field-name="false"
                :required="true"
                :readonly="cf.customFieldGroupAssignmentId === ProposalCFGAIDs.ESTIMATED_ANNUAL_CONSUMPTION"
                custom-class="albatross-body-2"
                :field="cf"
            ></CustomValueInput>
          </div>
        </v-form>
      </v-card-text>

      <v-card-actions>
        <v-spacer />
        <a-btn
            variant="text"
            color="primary"
            @click="emit('close')"
            text="Cancel"
        ></a-btn>
        <a-btn
            color="primary"
            :loading="savingNewAiDesign"
            class="font-weight-bold"
            @click="emit('save')"
            text="Save"
        ></a-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>

</template>

<style scoped lang="scss">

</style>
