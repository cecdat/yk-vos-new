<script lang="ts" setup>
import type { VosInstanceApi } from '#/api/vos';

import { computed, ref } from 'vue';

import { useVbenModal } from '@vben/common-ui';

import { ElMessage } from 'element-plus';

import { useVbenForm } from '#/adapter/form';
import {
  createVosInstance,
  getVosInstance,
  updateVosInstance,
} from '#/api/vos';
import { $t } from '#/locales';

import { useFormSchema } from '../data';

const emit = defineEmits(['success']);
const formData = ref<VosInstanceApi.VosInstance>();
const getTitle = computed(() => {
  return formData.value?.id
    ? $t('ui.actionTitle.edit', ['VOS 实例'])
    : $t('ui.actionTitle.create', ['VOS 实例']);
});

const [Form, formApi] = useVbenForm({
  commonConfig: {
    componentProps: {
      class: 'w-full',
    },
    formItemClass: 'col-span-2',
    labelWidth: 80,
  },
  layout: 'horizontal',
  schema: useFormSchema(),
  showDefaultActions: false,
});

const [Modal, modalApi] = useVbenModal({
  async onConfirm() {
    const { valid } = await formApi.validate();
    if (!valid) {
      return;
    }
    modalApi.lock();
    // 提交表单
    const data =
      (await formApi.getValues()) as VosInstanceApi.VosInstance;
    try {
      if (formData.value?.id) {
        await updateVosInstance(formData.value.id, data);
      } else {
        await createVosInstance(data);
      }
      // 关闭并提示
      await modalApi.close();
      emit('success');
      ElMessage.success($t('ui.actionMessage.operationSuccess'));
    } finally {
      modalApi.unlock();
    }
  },
  async onOpenChange(isOpen: boolean) {
    if (!isOpen) {
      formData.value = undefined;
      return;
    }
    // 新增时默认启用
    const data = modalApi.getData<VosInstanceApi.VosInstance>();
    if (!data || !data.id) {
      await formApi.setValues({ enabled: true });
      return;
    }
    modalApi.lock();
    try {
      formData.value = await getVosInstance(data.id);
      // 设置到 values
      await formApi.setValues(formData.value);
    } finally {
      modalApi.unlock();
    }
  },
});
</script>

<template>
  <Modal :title="getTitle">
    <Form class="mx-4" />
  </Modal>
</template>
