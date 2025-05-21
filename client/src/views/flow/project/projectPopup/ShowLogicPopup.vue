<!-- eslint-disable vuetify/no-deprecated-classes -->
<template>
    <v-dialog max-width="500" v-model="showActionPopup">



        <v-card title="Dialog">
            <v-card-text>


                <div>

                    <span v-for="(l, index) in actionButtnInfo.processStepLogicList.filter(a => !a.archived)"
                        :key="index">
                        <v-tooltip bottom max-width="300px">
                            <template v-slot:activator="{ on, attrs }">
                                <v-btn  class="ml-1 mr-1 mt-1" v-bind="attrs" v-on="on"> {{ true && l.requirementNbr ?
                                    l.requirementNbr : getLogicButtonText(l) }}</v-btn>
                            </template>
                               <span>
                            {{ false && l.requirementNbr ? l.requirementNbr : getLogicButtonText(l) }}
                            </span>
                        </v-tooltip>


                    </span>

                </div>
            </v-card-text>

            <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn text="Close"></v-btn>
                <v-btn text="Delete"></v-btn>


            </v-card-actions>
        </v-card>

    </v-dialog>
</template>

<script setup>
import { ref } from 'vue'

const props = defineProps({
    actionButtnInfo: {
        type: Object,
        required: true
    },
    showActionPopup: {
        type: Boolean,
        required: true
    }

})


const getLogicButtonText = (item) => {
    if (item.logicString) {
        //this part make it work when clicking a requirement and adding to the current logic section, otherwise unused
        return item.logicString
    } else {
        if (null != item.requirementNbr) {
            //if not a system requirement (like AND, NOT, OR, etc)
            let value = ''
            if (item.dataTypeRequirement?.dataTypeValue) {
                value = item.dataTypeRequirement?.dataTypeValue
            } else if (item.listOfValue?.name) {
                value = item.listOfValue?.name
            } else if (item.listOfValues?.length > 0) {
                item.listOfValues.forEach((lv, idx) => {
                    if (idx !== 0) {
                        value = value + ', '
                    }
                    value = value + lv.name
                })
            } else if (item.requirementValue) {
                value = item.requirementValue
            } else {
                value = 'UNKNOWN CONTACT ADMIN'
            }
            if (null != item.secondaryRequirementValue) {
                value = value + ` (${item.secondaryRequirementValue})`
            }
            if ([1, 3, 4].includes(item.processStepRequirementTypeId)) {
                //custom field
                let textStart = item.processStepRequirementTypeId === 1 ? item.parentName : item.processStepRequirementType
                let logicString = textStart + ' - ' + item.fieldName + ' ' + item.operatorType + ' ' + value
                item.logicString = logicString
                return logicString
            } else if (item.processStepRequirementTypeId === 2) {
                //function
                let logicString = item.processStepRequirementType + ' - ' + item.companyFunctionName + ' ' + item.operatorType + ' ' + value
                item.logicString = logicString
                return logicString
            } else if (item.processStepRequirementTypeId === 12) {
                //function
                let logicString = item.processStepRequirementType + ' - ' + item.dataViewFieldName + ' ' + item.operatorType + ' ' + value
                item.logicString = logicString
                return logicString
            } else if ([7, 8, 9, 10].includes(item.processStepRequirementTypeId)) {
                //status (project or process step)
                let referenceText = item.referenceProcessStepName ? ` - ${item.referenceProcessStepName}` : ''
                let logicString = item.processStepRequirementType + referenceText + ' ' + item.operatorType + ' ' + value
                item.logicString = logicString
                return logicString
            }
        } else {
            //this returns if AND, OR, NOT, etc
            return item.operationType
        }
    }
}



</script>