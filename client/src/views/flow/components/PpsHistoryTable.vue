<template>
  <v-data-table
      id="pps-history-table"
    :headers="historyHeaders"
    :items="selectedPpsHistory"
    disable-sort
    :fixed-header="true"
    :items-per-page="-1"
      :footer-props="footerProps"
    class="elevation-1 table-striped">

    <template #no-data>
      <span class="default-text-color">No available history data</span>
    </template>

    <template #no-results>
      <span class="default-text-color">No available history data</span>
    </template>


        <template #item.owner="{ item }" class="text-left">{{item.owner}}</template>
        <template #item.processStepStatusType="{ item }" class="text-left">{{item.companyProcessStepStatusType}}</template>
        <template #item.main="{ item }" class="text-left">{{item.main ? 'Yes' : 'No'}}</template>
        <template #item.dateCreated="{ item, index }" class="text-left">
          <div v-if="index === 0">
            {{item.dateCreated | formatDate('timestamp', 'M/D/YYYY h:mm:ss a')}}
          </div>
        </template>
        <template #item.createdBy="{ item, index }" class="text-left">
          <div v-if="index === 0">
            {{item.createdBy}}
          </div>
        </template>
        <template #item.dateModified="{ item }" class="text-left">{{item.dateModified | formatDate('timestamp', 'M/D/YYYY h:mm:ss a')}}</template>
        <template #item.modifiedBy="{ item }" class="text-left">{{item.modifiedBy}}</template>
  </v-data-table>
</template>

<script>
export default {
  name: 'PpsHistory',
  props: {
    selectedPpsHistory: Array
  },
  data () {
    return {
      historyHeaders: [
        {text: 'Owner', value: 'owner'},
        {text: 'Status', value: 'processStepStatusType'},
        {text: 'Is Primary?', value: 'main'},
        {text: 'Date Created', value: 'dateCreated'},
        {text: 'Created By', value: 'createdBy'},
        {text: 'Date Modified', value: 'dateModified'},
        {text: 'Modified By', value: 'modifiedBy'},
      ],
      footerProps: {
        'items-per-page-text': this.isMobile ? '' : 'Rows per page: '
      },
    }
  },
  created () {

  },
  methods: {

  },
  computed: {
    isMobile(){
      return this.$vuetify.breakpoint.smAndDown
    }
  }
}
</script>

<style lang="scss">
.add-process-step-btn > .v-btn__content {
  color: white !important;
}
#pps-history-table > div.v-data-table__wrapper {
  max-height: 55vh;
}

@media (max-width: 770px) {
  #pps-history-table {
    div.v-data-footer {
      display: inline-flex;
      width: 100%;
      justify-content: center;
      height: fit-content;

      div.v-data-footer__select {
        justify-content: center;
        margin-left:0;
        margin-right:0;
      }

      div.v-data-footer__pagination {
        margin: 0 16px 0 16px !important;
      }

      div.v-data-footer__icons-before {
        display: inline;
        //margin-left: calc(50% - 36px);


      }

      div.v-data-footer__icons-after {
        display: inline;
      }

    }
  }
}
</style>

