<template>
  <v-container class="bracket-container">
    <div :style="{'min-width': minWidth}" class="bracket-div">
      <v-row v-for="row in rowCount" class="bracket-row pt-0" :style="{'min-width': minWidth}" >
        <BracketComponent class="d-inline-block"
                          v-for="(b, idx) in getBrackets(row)"
                          :bracket-count="bracketCount"
                          :row-number="row"
                          :bracket="b" :reverse="idx % 2 !== 0"></BracketComponent>

      </v-row>
    </div>

  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import BracketComponent from "./component/BracketComponent";
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'

  export default {
    name: 'Bracket',
    components: {
      BracketComponent
    },
    data() {
      return {
        constants,
        snackbar: {},
        tournament: {},
        bracketCount: 0,
        rowCount: 1,
        tournamentId: this.$route.params.id
      }
    },
    computed: {
      minWidth () {
        if(this.tournament?.brackets?.length > 0) {
          let roundCount = this.tournament?.brackets[0].rounds?.length
          if(this.bracketCount === 0) {
            return roundCount * 175 + 'px'
          } else {
            return (roundCount * 175 * 2) + 'px'
          }
        }
      }
    },
    async created() {
      this.getTournament()
    },
    methods: {
      getBrackets(rowNum) {
        // bracketCount 1, 0
        // bracketCount 2, 0,1  row 1
        // bracketCount 4, 2,3  row 2
        // bracketCount 6, 4,5  row 3
        let results = []
        let validIdx = []
        if (this.bracketCount === 1) {
          results = this.tournament.brackets
        } else {
          if (rowNum === 1) {
            validIdx = [0, 1]
          } else if (rowNum === 2) {
            validIdx = [2, 3]
          } else if (rowNum === 3) {
            validIdx = [4, 5]
          } else if (rowNum === 4) {
            validIdx = [6, 7]
          }
          results = this.tournament?.brackets?.filter((b, idx) => {
            return validIdx.includes(idx)
          })
        }
        return results
      },
      async getTournament() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/tournament/${this.tournamentId}`, 'blueraven')
          this.tournament = data
          this.bracketCount = this.tournament.brackets.length
          this.rowCount = Math.ceil(this.bracketCount / 2)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Tournament')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    }
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>
.bracket-container {
  overflow: auto;
  width: 100%;
  height: calc(100vh - 104px);
  /*overflow-y: hidden;*/
  /*padding: 0;*/
}
.bracket-div {
  /*max-height: calc(100vh - 175px);*/

}
.bracket-row {
  display: flex;
  justify-content: space-between;
}
</style>

