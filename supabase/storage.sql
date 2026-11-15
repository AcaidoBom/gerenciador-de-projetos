-- Bucket privado para anexos do Gerenciador de Projetos.
-- Cada usuário só pode listar, enviar, baixar e remover arquivos dentro da pasta do próprio UUID.
-- Limite por arquivo: 30 MB. Limite total do app: 1 GB (validado na interface).

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'private-files',
  'private-files',
  false,
  31457280,
  array['image/*', 'application/pdf', 'audio/*', 'video/mp4']
)
on conflict (id) do update set
  name = excluded.name,
  public = false,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Private files: read own" on storage.objects;
create policy "Private files: read own"
on storage.objects for select to authenticated
using (
  bucket_id = 'private-files'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

drop policy if exists "Private files: upload own" on storage.objects;
create policy "Private files: upload own"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'private-files'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

drop policy if exists "Private files: update own" on storage.objects;
create policy "Private files: update own"
on storage.objects for update to authenticated
using (
  bucket_id = 'private-files'
  and (storage.foldername(name))[1] = (select auth.uid())::text
)
with check (
  bucket_id = 'private-files'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

drop policy if exists "Private files: delete own" on storage.objects;
create policy "Private files: delete own"
on storage.objects for delete to authenticated
using (
  bucket_id = 'private-files'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

