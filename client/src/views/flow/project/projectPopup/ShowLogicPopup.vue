<!-- eslint-disable vuetify/no-deprecated-classes -->
<template>
    <v-dialog max-width="800" v-model="showActionPopup" persistent>

        <v-card class="sys-p-1rem ">


            <div class="d-flex flex-column sys-w-100 ">
                <div class="d-flex align-center  justify-space-between  sys-w-100 sys-p-0_5rem">
                    <span class="black-color">{{ actionButtnInfo?.actionName }}</span>

                    <div class="d-flex align-center " style="gap:12px;height: 1rem;">
                        <span class="check-logic">Logic Text</span>
                        <v-switch color="primary" v-model="showText" class="sys-hover"></v-switch>
                    </div>


                </div>
                <span class="sys-p-0_5rem logic-chicker">Logic Checker</span>
            </div>


            <div class="sys-p-0_5rem showLogicScroll">

                <span v-if="actionButtnInfo?.processStepLogicList.length === 0"> No Action Is Available</span>
                <span v-else>
                    <span v-for="(l, index) in actionButtnInfo?.processStepLogicList?.filter(a => !a.archived)"
                        :key="index">
                        <v-tooltip bottom max-width="300px">
                            <template v-slot:activator="{ on, attrs }">
                                <v-btn class="ml-1 mr-1 mt-1 mb-1 " v-bind="attrs" v-on="on"
                                    :class="l.isPassAction ? 'green' : 'red'"> {{ !showText && l.requirementNbr ?
                                        l.requirementNbr : getLogicButtonText(l) }}</v-btn>
                            </template>
                            <span>
                                {{ showText && l.requirementNbr ? l.requirementNbr : getLogicButtonText(l) }}
                            </span>
                        </v-tooltip>
                    </span>
                </span>
            </div>


            <div class="d-flex align-center justify-end sys-p-0_5rem">


                <span class="close sys-hover" @click="closePopup">Close</span>

            </div>
        </v-card>

    </v-dialog>
</template>

<script setup>
import { ref, defineEmits, defineProps } from 'vue'

const showText = ref(false)

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
const emit = defineEmits(['closePopup'])

const closePopup = () => {
    emit('closePopup', false)
}

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

<style scoped>
.sys-w-100 {
    width: 100% !important;
}

.sys-p-1rem {
    padding: 1rem !important;
}

.sys-p-0_5rem {
    padding: 0.5rem !important;
}

.logic-chicker {
    color: #5796cb;
    font-size: smaller;
}

.close {
    color: #1f3c73;
}

.check-logic {
    color: #898383;

}

.black-color {
    color: black;
}

.showLogicScroll {

    overflow-x: auto;
    overflow-y: auto;
}

.sys-hover:hover {
    cursor: pointer !important;
}

.green {
    background-color: rgb(194, 241, 194) !important;
}

.red {
    background-color: #fecdd2 !important;
}
</style>