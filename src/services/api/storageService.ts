import { supabase } from './supabase';

const BUCKET_NAME = 'market-media';

/**
 * Upload single media file (gambar/video) ke Supabase Storage bucket `market-media`
 * @param file File object dari input
 * @param folder Subfolder tempat menyimpan file (default: 'posts')
 * @returns Public URL dari file yang di-upload
 */
export async function uploadMarketMedia(file: File, folder: string = 'posts'): Promise<string> {
  const fileExt = file.name.split('.').pop();
  const fileName = `${folder}/${Date.now()}_${Math.random().toString(36).substring(2, 9)}.${fileExt}`;

  const { error: uploadError } = await supabase.storage
    .from(BUCKET_NAME)
    .upload(fileName, file, {
      cacheControl: '3600',
      upsert: false
    });

  if (uploadError) {
    console.error('Error uploading file to Supabase storage:', uploadError.message);
    throw uploadError;
  }

  // Mendapatkan public URL
  const { data } = supabase.storage
    .from(BUCKET_NAME)
    .getPublicUrl(fileName);

  return data.publicUrl;
}

/**
 * Upload multiple media files secara sekuensial/paralel
 * @param files Array of File objects
 * @param folder Subfolder tempat menyimpan
 * @returns Array of public URLs
 */
export async function uploadMultipleMarketMedia(files: File[], folder: string = 'posts'): Promise<string[]> {
  const uploadPromises = files.map((file) => uploadMarketMedia(file, folder));
  return Promise.all(uploadPromises);
}

/**
 * Hapus file dari Supabase Storage `market-media` berdasarkan relative path file
 */
export async function deleteMarketMedia(filePath: string): Promise<void> {
  const { error } = await supabase.storage
    .from(BUCKET_NAME)
    .remove([filePath]);

  if (error) {
    console.error(`Error deleting file ${filePath} from Supabase storage:`, error.message);
    throw error;
  }
}
