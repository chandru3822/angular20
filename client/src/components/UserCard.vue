<template>
<v-card class="card">
  <v-card-text>
    <v-row no-gutters>
    <v-col>
      <v-row align="center" no-gutters>
        <v-col
          v-if="imageUrl"
          offset="1"
          class="image-container"
        >
          <v-img :src="imageUrl" class="image"/></v-col>
        <v-col class="text-left name">{{ name }}</v-col>
      </v-row>
    </v-col>
  </v-row>
  <v-row>
    <v-col cols="12">{{ role }} | {{ location }}</v-col>
  </v-row>
  </v-card-text>
</v-card>
</template>

<script>
export default {
  name: 'UserCard',
  props: {
    name: String,
    role: String,
    location: String,
    imageUrl: String
  }
}
</script>


<style scoped lang="scss">
.card {
  font-size: 14px;
  font-weight: bold;
  width: 200px;
}

.image-container {
  flex-grow: 0;
  margin-left: 5px;
  margin-right: 5px;
}

.name {
  font-size: 16px;
}

.image {
  width: 30px;
  height: 30px;
  border-radius: 15px;
}
</style>
