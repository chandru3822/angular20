<template>
  <v-card
    flat
    outlined
    width="394px"
    class="ma-4">
    <v-card-text>
<!--      title-->
      <span class="default-text-color" v-if="query.length > 0" :inner-html.prop="title | searchHighlight(query)"/>
      <span v-else class="default-text-color">{{ title }}</span>
      <br>

<!--      UPDATED VALUES-->
      <span class="default-text-color" v-if="query.length > 0" :inner-html.prop="`Updated: ${updatedValueData}` | searchHighlight(query)"/>
      <span v-else class="default-text-color">
        <template v-if="dataType === 1 && updatedValue   !== null">
          Previous: {{ updatedValueData | formatDate('date', 'MMM DD, y') }}
        </template>
        <template v-else-if="dataType === 2 && updatedValue !== null">
          Updated: {{ updatedValueData | formatDate('timestamp', 'MMMM DD, YYYY, hh:mm A') }}
        </template>
        <template v-else>
          Updated: {{ updatedValueData }}
        </template>
        <a class="seeValue" v-if="!seeMoreUpdatedValues && showUpdatedSeeButton && expandAll === false" @click="seeMoreUpdatedValues = !seeMoreUpdatedValues">...see more</a>
        <a class="seeValue"  v-if="seeMoreUpdatedValues && showUpdatedSeeButton && expandAll === false" @click="seeMoreUpdatedValues = !seeMoreUpdatedValues">...see less</a>
      </span>
      <br>

<!--      PREVIOUS VALUES-->
      <span class="previousValue" v-if="query.length > 0" :inner-html.prop="`Previous: ${previousValueData}` | searchHighlight(query)"/>
      <span v-else class="previousValue">
        <template v-if="dataType === 1 && previousValue !== null">
          Previous: {{ previousValueData | formatDate('date', 'MMM DD, y') }}
        </template>
        <template v-else-if="dataType === 2 && previousValue !== null">
          Previous: {{ previousValueData | formatDate('timestamp', 'MMMM DD, YYYY, hh:mm A') }}
        </template>
        <template v-else>
          Previous: {{ previousValueData }}
        </template>
        <a class="seeValue" v-if="!seeMorePreviousValues && showPreviousSeeButton && expandAll === false" @click="seeMorePreviousValues = !seeMorePreviousValues">...see more</a>
        <a class="seeValue"  v-if="seeMorePreviousValues && showPreviousSeeButton && expandAll === false" @click="seeMorePreviousValues = !seeMorePreviousValues">...see less</a>
      </span>
      <br>

<!--      USER AND DATE-->
      <span class="user-and-date" v-if="query.length > 0" :inner-html.prop="`${modifiedBy} | ${dateModified}` | searchHighlight(query)"/>
      <span v-if="query.length === 0" class="user-and-date">
          {{ modifiedBy }} | {{ dateModified | formatDate('timestamp', 'MM/DD/YYYY') }} at {{ dateModified | formatDate('timestamp', 'hh:mm a') }}
      </span>
    </v-card-text>
  </v-card>
</template>

<script setup>
import { ref, toRefs, defineProps, computed, onMounted } from 'vue'

const props = defineProps({
  title: {
    required: true,
  },
  updatedValue: {
    required: true,
  },
  previousValue: {
    required: true,
  },
  modifiedBy: {
    required: true,
  },
  dateModified: {
    required: true,
  },
  dataType: {
    required: true,
  },
  expandAll: {
    required: false,
    default: false,
  },
  query: {
    required: false,
    default: '',
  }
})



const { title, updatedValue, previousValue, modifiedBy, dateModified, expandAll, query, dataType } = toRefs(props)


const seeMoreUpdatedValues = ref(false)
const seeMorePreviousValues = ref(false)

const showUpdatedSeeButton = computed(() => {
  return updatedValue.value?.length > 125 || false
})
const showPreviousSeeButton = computed(() => {
  return previousValue.value?.length > 125 || false
})

const updatedValueData = computed(() => {
  // 125 is just a generic number. blue raven just wanted around 3 lines of content
  if (updatedValue.value !== null && updatedValue.value.length > 125 && seeMoreUpdatedValues.value === false && expandAll.value === false) {
    return updatedValue.value.slice(0, 125)
  } else {
    return (updatedValue.value === null || updatedValue.value === '') ? '[null]' : updatedValue.value
  }
})

const previousValueData = computed(() => {
  if (previousValue.value !== null && previousValue.value.length > 125 && seeMorePreviousValues.value === false && expandAll.value === false) {
    return previousValue.value.slice(0, 125)
  } else {
    return (previousValue.value === null || previousValue.value === '') ? '[null]' : previousValue.value
  }
})

</script>

<style scoped>

.seeValue {
  color: var(--v-primary-base);
}
.seeValue:hover {
  text-decoration: underline;
  cursor: pointer;
}

.previousValue {
  color: var(--v-grey-darken1);
}
.user-and-date {
  color: var(--v-grey-darken2);
}
</style>
