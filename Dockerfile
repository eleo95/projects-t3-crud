FROM arm64v8/node:16-slim AS dependencies

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install

FROM arm64v8/node:16-slim AS build

WORKDIR /app
COPY --from=dependencies /app/node_modules ./node_modules
COPY . .

RUN npx prisma generate
RUN npm run build

FROM arm64v8/:16-slim AS deploy

WORKDIR /app

ENV  NODE_ENV production

COPY --from=build /app/public ./public
COPY --from=build /app/package.json ./package.json 
COPY --from=build /app/.next/standalone ./
COPY --from=build /app/.next/static ./.next/static

EXPOSE 3000

ENV PORT 3000

CMD ["node","server.js"]


